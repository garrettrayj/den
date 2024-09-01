//
//  DataController.swift
//  Den
//
//  Created by Garrett Johnson on 12/26/22.
//  Copyright © 2022 Garrett Johnson. All rights reserved.
//

import CoreData
import OSLog

struct DataController {
    static let shared = DataController()
    
    let container: NSPersistentCloudKitContainer
    
    init(inMemory: Bool = CommandLine.arguments.contains("-in-memory")) {
        container = NSPersistentCloudKitContainer(name: "Den")
        
        let cloudStoreDescription: NSPersistentStoreDescription
        let localStoreDescription: NSPersistentStoreDescription

        if inMemory {
            let cloudStoreURL = URL(fileURLWithPath: "/dev/null/Den.sqlite")
            let localStoreURL = URL(fileURLWithPath: "/dev/null/Den-Local.sqlite")

            // Create Cloud store description without `cloudKitContainerOptions`
            cloudStoreDescription = NSPersistentStoreDescription(url: cloudStoreURL)
            cloudStoreDescription.cloudKitContainerOptions = nil
            
            // Create local store description
            localStoreDescription = NSPersistentStoreDescription(url: localStoreURL)
        } else {
            guard 
                let appSupportDirectory = FileManager.default.appSupportDirectory,
                let appGroupURL = AppGroup.den.containerURL?.appending(
                    path: "Library/Application Support",
                    directoryHint: .isDirectory
                )
            else {
                preconditionFailure("Storage directory not available")
            }
            
            let cloudStoreURL = appSupportDirectory.appending(path: "Den.sqlite")
            let cloudStoreAppGroupURL = appGroupURL.appending(path: "Den.sqlite")
            
            let localStoreURL = appSupportDirectory.appending(path: "Den-Local.sqlite")
            let localStoreAppGroupURL = appGroupURL.appending(path: "Den-Local.sqlite")
            
            migrateDatabaseIfNeeded(source: cloudStoreURL, destination: cloudStoreAppGroupURL)
            migrateDatabaseIfNeeded(source: localStoreURL, destination: localStoreAppGroupURL)
            
            // Create CloudKit-backed store description for syncing profile data
            cloudStoreDescription = NSPersistentStoreDescription(url: cloudStoreAppGroupURL)
            cloudStoreDescription.cloudKitContainerOptions = NSPersistentCloudKitContainerOptions(
                containerIdentifier: "iCloud.net.devsci.den"
            )
            
            // Create local store description for content and high churn data
            localStoreDescription = NSPersistentStoreDescription(url: localStoreAppGroupURL)
        }
        
        cloudStoreDescription.configuration = "Cloud"
        localStoreDescription.configuration = "Local"

        container.persistentStoreDescriptions = [cloudStoreDescription, localStoreDescription]
        container.loadPersistentStores { _, error in
            guard error == nil else {
                /*
                Typical reasons for an error here include:
                 
                - The parent directory does not exist, cannot be created, or disallows writing.
                - The persistent store is not accessible, due to permissions or data protection
                  when the device is locked.
                - The device is out of space.
                - The store could not be migrated to the current model version.
                */
                CrashUtility.handleCriticalError(error! as NSError)
                return
            }
        }

        // Configure view context
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergePolicy(
            merge: .mergeByPropertyObjectTrumpMergePolicyType
        )
    }
    
    private func migrateDatabaseIfNeeded(source: URL, destination: URL) {
        guard 
            FileManager.default.fileExists(atPath: source.path),
            !FileManager.default.fileExists(atPath: destination.path) 
        else {
            return
        }
        
        Logger.main.debug("Moving database from \(source) to \(destination)")
        
        let coordinator = container.persistentStoreCoordinator
        do {
            try coordinator.replacePersistentStore(
                at: destination,
                destinationOptions: nil,
                withPersistentStoreFrom: source,
                sourceOptions: nil,
                ofType: NSSQLiteStoreType
            )
            try? coordinator.destroyPersistentStore(
                at: source,
                ofType: NSSQLiteStoreType,
                options: nil
            )
            
            // destroyPersistentStore says it deletes the old store
            // but it actually truncates so we'll manually delete the files
            NSFileCoordinator(filePresenter: nil).coordinate(
                writingItemAt: source.deletingLastPathComponent(),
                options: .forDeleting,
                error: nil,
                byAccessor: { _ in
                    try? FileManager.default.removeItem(at: source)
                    try? FileManager.default.removeItem(
                        at: source
                            .deletingPathExtension()
                            .appendingPathExtension("sqlite-shm")
                    )
                    try? FileManager.default.removeItem(
                        at: source
                            .deletingPathExtension()
                            .appendingPathExtension("sqlite-wal")
                    )
                    try? FileManager.default.removeItem(
                        at: source
                            .deletingLastPathComponent()
                            .appendingPathComponent("\(container.name)_ckAssets")
                    )
            })
        } catch {
            Logger.main.error("""
            Error moving database \(source) to \(destination):
            \(error.localizedDescription)
            """)
            CrashUtility.handleCriticalError(error as NSError)
        }
    }
    
    /// More performant truncate function to use when the UI doesn't need to be updated.
    static func truncate(
        _ entityType: NSManagedObject.Type,
        context: NSManagedObjectContext,
        sortDescriptors: [NSSortDescriptor] = [],
        offset: Int = 0
    ) {
        let fetchRequest = entityType.fetchRequest()
        fetchRequest.fetchOffset = offset
        fetchRequest.sortDescriptors = sortDescriptors
        
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)

        // Specify the result of the NSBatchDeleteRequest
        // should be the NSManagedObject IDs for the deleted objects
        deleteRequest.resultType = .resultTypeObjectIDs
        
        context.performAndWait {
            do {
                // Perform the batch delete
                let batchDelete = try context.execute(deleteRequest) as? NSBatchDeleteResult

                guard let deleteResult = batchDelete?.result as? [NSManagedObjectID] else { return }

                let deletedObjects: [AnyHashable: Any] = [NSDeletedObjectsKey: deleteResult]

                // Merge the delete changes into the managed object context
                NSManagedObjectContext.mergeChanges(fromRemoteContextSave: deletedObjects, into: [context])
            } catch {
                CrashUtility.handleCriticalError(error as NSError)
            }
        }
    }
}
