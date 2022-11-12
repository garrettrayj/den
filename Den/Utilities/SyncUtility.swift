//
//  SyncUtility.swift
//  Den
//
//  Created by Garrett Johnson on 11/12/21.
//  Copyright © 2021 Garrett Johnson. All rights reserved.
//

import CoreData
import SwiftUI
import OSLog

struct SyncUtility {
    static func markItemRead(container: NSPersistentContainer?, item: Item) async {
        guard item.read != true else { return }
        await logHistory(container: container, items: [item])
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1, qos: .utility) {
            NotificationCenter.default.postItemStatus(
                read: true,
                itemObjectID: item.objectID,
                feedObjectID: item.feedData?.feed?.objectID,
                pageObjectID: item.feedData?.feed?.page?.objectID,
                profileObjectID: item.feedData?.feed?.page?.profile?.objectID
            )
        }
    }

    static func markItemUnread(container: NSPersistentContainer, item: Item) async {
        guard item.read != false else { return }
        item.read = false
        await clearHistory(container: container, items: [item])
        
        DispatchQueue.main.async {
            NotificationCenter.default.postItemStatus(
                read: false,
                itemObjectID: item.objectID,
                feedObjectID: item.feedData?.feed?.objectID,
                pageObjectID: item.feedData?.feed?.page?.objectID,
                profileObjectID: item.feedData?.feed?.page?.profile?.objectID
            )
        }
    }

    static func toggleReadUnread(container: NSPersistentContainer?, items: [Item]) async {
        var modItems: [Item]

        if items.unread().isEmpty == true {
            modItems = items.read()
            await clearHistory(container: container, items: modItems)
        } else {
            modItems = items.unread()
            await logHistory(container: container, items: modItems)
        }
        
        modItems.forEach { item in
            DispatchQueue.main.async {
                NotificationCenter.default.postItemStatus(
                    read: item.read,
                    itemObjectID: item.objectID,
                    feedObjectID: item.feedData?.feed?.objectID,
                    pageObjectID: item.feedData?.feed?.page?.objectID,
                    profileObjectID: item.feedData?.feed?.page?.profile?.objectID
                )
            }
        }
    }

    static func logHistory(container: NSPersistentContainer?, items: [Item]) async {
        guard let profileObjectID = items.first?.feedData?.feed?.page?.profile?.objectID else { return }
        let itemObjectIDs = items.map { $0.objectID }
        
        await container?.performBackgroundTask { context in
            guard let profile = context.object(with: profileObjectID) as? Profile else { return }
            for itemObjectID in itemObjectIDs {
                guard let item = context.object(with: itemObjectID) as? Item else { return }
                item.read = true

                let history = item.history.first ?? History.create(in: context, profile: profile)
                history.link = item.link
                history.title = item.title
                history.visited = .now
            }
            
            do {
                try context.save()
            } catch {
                CrashUtility.handleCriticalError(error as NSError)
            }
        }
    }

    static func clearHistory(container: NSPersistentContainer?, items: [Item]) async {
        let itemObjectIDs = items.map { $0.objectID }

        await container?.performBackgroundTask { context in
            for itemObjectID in itemObjectIDs {
                guard let item = context.object(with: itemObjectID) as? Item else { return }
                item.read = false
                for history in item.history {
                    context.delete(history)
                }
            }
            
            do {
                try context.save()
            } catch {
                CrashUtility.handleCriticalError(error as NSError)
            }
        }
    }

    static func resetHistory(container: NSPersistentContainer?, profile: Profile) async {
        let profilePredicate = NSPredicate(
            format: "profile.id == %@",
            profile.id?.uuidString ?? ""
        )

        // Specify a batch to delete with a fetch request
        let fetchRequest: NSFetchRequest<NSFetchRequestResult>
        fetchRequest = NSFetchRequest(entityName: "History")
        fetchRequest.predicate = profilePredicate

        // Create a batch delete request for the fetch request
        let deleteRequest = NSBatchDeleteRequest(
            fetchRequest: fetchRequest
        )

        // Specify the result of the NSBatchDeleteRequest
        // should be the NSManagedObject IDs for the deleted objects
        deleteRequest.resultType = .resultTypeObjectIDs

        // Perform the batch delete
        await container?.performBackgroundTask { context in
            let batchDelete = try? context.execute(deleteRequest) as? NSBatchDeleteResult

            guard let deleteResult = batchDelete?.result as? [NSManagedObjectID]
                else { return }

            let deletedObjects: [AnyHashable: Any] = [NSDeletedObjectsKey: deleteResult]

            // Merge the delete changes into the managed object context
            NSManagedObjectContext.mergeChanges(
                fromRemoteContextSave: deletedObjects,
                into: [context]
            )

            // Update items
            profile.previewItems.forEach { $0.read = false }

            do {
                try context.save()
            } catch {
                CrashUtility.handleCriticalError(error as NSError)
            }
        }
    }
}
