//
//  Persistence.swift
//  Den
//
//  Created by Garrett Johnson on 12/26/22.
//  Copyright © 2020 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import CoreData
import OSLog

struct PersistenceController {
    static let shared = PersistenceController(
        inMemory: CommandLine.arguments.contains("-in-memory")
    )

    let cloudKitContainerOptions = NSPersistentCloudKitContainerOptions(
        containerIdentifier: "iCloud.net.devsci.den"
    )
    
    let container = NSPersistentCloudKitContainer(name: "Den")
    
    init(inMemory: Bool = false) {
        let cloudStoreDescription: NSPersistentStoreDescription
        let cloudStoreURL: URL
        let cloudStoreAppGroupURL: URL

        let localStoreDescription: NSPersistentStoreDescription
        let localStoreURL: URL
        let localStoreAppGroupURL: URL

        if inMemory {
            cloudStoreURL = URL(fileURLWithPath: "/dev/null/Den.sqlite")
            localStoreURL = URL(fileURLWithPath: "/dev/null/Den-Local.sqlite")

            // Create Cloud store description without `cloudKitContainerOptions`
            cloudStoreDescription = NSPersistentStoreDescription(url: cloudStoreURL)
            cloudStoreDescription.configuration = "Cloud"

            // Create local store description
            localStoreDescription = NSPersistentStoreDescription(url: localStoreURL)
            localStoreDescription.configuration = "Local"
        } else {
            guard let appSupportDirectory = FileManager.default.appSupportDirectory else {
                preconditionFailure("Storage directory not available")
            }
            
            let appGroupURL = AppGroup.den.containerURL.appending(path: "Library/Application Support")
            
            cloudStoreURL = appSupportDirectory.appending(path: "Den.sqlite")
            cloudStoreAppGroupURL = appGroupURL.appending(path: "Den.sqlite")
            
            localStoreURL = appSupportDirectory.appending(path: "Den-Local.sqlite")
            localStoreAppGroupURL = appGroupURL.appending(path: "Den-Local.sqlite")
            
            moveDB(source: cloudStoreURL, destination: cloudStoreAppGroupURL)
            moveDB(source: localStoreURL, destination: localStoreAppGroupURL)
            
            // Create CloudKit-backed store description for syncing profile data
            cloudStoreDescription = NSPersistentStoreDescription(url: cloudStoreAppGroupURL)
            cloudStoreDescription.configuration = "Cloud"

            // Create local store description for content and high churn data
            localStoreDescription = NSPersistentStoreDescription(url: localStoreAppGroupURL)
            localStoreDescription.configuration = "Local"
        }

        if inMemory {
            cloudStoreDescription.cloudKitContainerOptions = nil
        } else {
            cloudStoreDescription.cloudKitContainerOptions = cloudKitContainerOptions
        }

        container.persistentStoreDescriptions = [cloudStoreDescription, localStoreDescription]

        // Load both stores
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
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
    }
    
    private func moveDB(source: URL, destination: URL) {
        // Move database to shared location if needed
        if FileManager.default.fileExists(atPath: source.path) && 
            !FileManager.default.fileExists(atPath: destination.path) {
            
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
    }
    
    /// More performant truncate function to use when the UI doesn't need to be updated.
    static func truncate(
        _ entityType: NSManagedObject.Type,
        context: NSManagedObjectContext,
        offset: Int = 0
    ) {
        let fetchRequest = entityType.fetchRequest()
        fetchRequest.fetchOffset = offset
        
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)

        // Specify the result of the NSBatchDeleteRequest
        // should be the NSManagedObject IDs for the deleted objects
        deleteRequest.resultType = .resultTypeObjectIDs

        do {
            // Perform the batch delete
            let batchDelete = try context.execute(deleteRequest) as? NSBatchDeleteResult

            guard let deleteResult = batchDelete?.result as? [NSManagedObjectID] else { return }

            let deletedObjects: [AnyHashable: Any] = [NSDeletedObjectsKey: deleteResult]

            // Merge the delete changes into the managed object context
            NSManagedObjectContext.mergeChanges(
                fromRemoteContextSave: deletedObjects,
                into: [context]
            )
        } catch {
            CrashUtility.handleCriticalError(error as NSError)
        }
    }
}
