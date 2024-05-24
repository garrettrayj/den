//
//  DataController.swift
//  Den
//
//  Created by Garrett Johnson on 12/26/22.
//  Copyright © 2020 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import CoreData
import OSLog

@Observable final class DataController {
    let container = NSPersistentCloudKitContainer(name: "Den")
    
    init() {
        let cloudStoreDescription: NSPersistentStoreDescription
        let localStoreDescription: NSPersistentStoreDescription

        if CommandLine.arguments.contains("-in-memory") {
            let cloudStoreURL = URL(fileURLWithPath: "/dev/null/Den.sqlite")
            let localStoreURL = URL(fileURLWithPath: "/dev/null/Den-Local.sqlite")

            // Create cloud store description without `cloudKitContainerOptions`
            cloudStoreDescription = NSPersistentStoreDescription(url: cloudStoreURL)
            cloudStoreDescription.cloudKitContainerOptions = nil
            
            // Create local store description
            localStoreDescription = NSPersistentStoreDescription(url: localStoreURL)
        } else {
            let fileManager = FileManager.default
            guard
                let applicationSupportDirectory = fileManager.appSupportDirectory,
                let groupApplicationSupportDirectory = fileManager.groupSupportDirectory
            else {
                preconditionFailure("Database storage directory not available")
            }
            
            let legacyCloudStoreURL = applicationSupportDirectory.appending(path: "Den.sqlite")
            let groupCloudStoreURL = groupApplicationSupportDirectory.appending(
                path: "Den.sqlite"
            )
            
            let legacyLocalStoreURL = applicationSupportDirectory.appending(path: "Den-Local.sqlite")
            let groupLocalStoreURL = groupApplicationSupportDirectory.appending(
                path: "Den-Local.sqlite"
            )
            
            migrateDatabaseIfNeeded(source: legacyCloudStoreURL, destination: groupCloudStoreURL)
            migrateDatabaseIfNeeded(source: legacyLocalStoreURL, destination: groupLocalStoreURL)
            
            // Create CloudKit-backed store description for syncing profile data
            cloudStoreDescription = NSPersistentStoreDescription(url: groupCloudStoreURL)
            cloudStoreDescription.cloudKitContainerOptions = NSPersistentCloudKitContainerOptions(
                containerIdentifier: "iCloud.net.devsci.den"
            )
            
            // Create local store description for content and high churn data
            localStoreDescription = NSPersistentStoreDescription(url: groupLocalStoreURL)
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
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
    }
    
    private func migrateDatabaseIfNeeded(source: URL, destination: URL) {
        let fileManager = FileManager.default
        guard
            fileManager.fileExists(atPath: source.path),
            !fileManager.fileExists(atPath: destination.path)
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
                    try? fileManager.removeItem(at: source)
                    try? fileManager.removeItem(
                        at: source.deletingPathExtension().appendingPathExtension("sqlite-shm")
                    )
                    try? fileManager.removeItem(
                        at: source.deletingPathExtension().appendingPathExtension("sqlite-wal")
                    )
                    try? fileManager.removeItem(
                        at: source.deletingLastPathComponent().appendingPathComponent(
                            "\(container.name)_ckAssets"
                        )
                    )
                }
            )
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
