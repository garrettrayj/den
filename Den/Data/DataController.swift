//
//  DataController.swift
//  Den
//
//  Created by Garrett Johnson on 12/26/22.
//  Copyright © 2020 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import OSLog
import SwiftData

struct DataController {
    static let shared = DataController(inMemory: CommandLine.arguments.contains("-in-memory"))
    
    let container: ModelContainer
    
    let cloudTypes: [any PersistentModel.Type] = [
        Blocklist.self,
        Bookmark.self,
        Feed.self,
        History.self,
        Page.self,
        Profile.self,
        Search.self,
        Tag.self
    ]
    
    let localTypes: [any PersistentModel.Type] = [
        BlocklistStatus.self,
        FeedData.self,
        Item.self,
        Trend.self,
        TrendItem.self
    ]
    
    init(inMemory: Bool = false) {
        let cloudStoreURL: URL
        let localStoreURL: URL
        
        if inMemory {
            cloudStoreURL = URL(fileURLWithPath: "/dev/null/Den.sqlite")
            localStoreURL = URL(fileURLWithPath: "/dev/null/Den-Local.sqlite")
        } else {
            guard let appGroupURL = AppGroup.den.containerURL?.appending(
                path: "Library/Application Support",
                directoryHint: .isDirectory
            ) else {
                fatalError("Storage directory not available")
            }
            cloudStoreURL = appGroupURL.appending(path: "Den.sqlite")
            localStoreURL = appGroupURL.appending(path: "Den-Local.sqlite")
        }

        do {
            let cloudConfig = ModelConfiguration(
                "Den",
                schema: Schema(cloudTypes),
                url: cloudStoreURL,
                allowsSave: true,
                cloudKitDatabase: .private("iCloud.net.devsci.den")
            )
            
            let localConfig = ModelConfiguration(
                "Den-Local",
                schema: Schema(localTypes),
                url: localStoreURL,
                allowsSave: true,
                cloudKitDatabase: .none
            )
            
            container = try ModelContainer(
                for:
                    // Cloud models
                    Blocklist.self,
                    Bookmark.self,
                    Feed.self,
                    History.self,
                    Page.self,
                    Profile.self,
                    Search.self,
                    Tag.self,
                    // Local models
                    BlocklistStatus.self,
                    FeedData.self,
                    Item.self,
                    Trend.self,
                    TrendItem.self,
                configurations: cloudConfig, localConfig
            )
        } catch {
            fatalError("Failed to configure SwiftData container.")
        }
    }
    
    /*
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
        context: ModelContext,
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
            ModelContext.mergeChanges(fromRemoteContextSave: deletedObjects, into: [context])
        } catch {
            CrashUtility.handleCriticalError(error as NSError)
        }
    }
     */
}
