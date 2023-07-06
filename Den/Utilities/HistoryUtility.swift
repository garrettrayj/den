//
//  HistoryUtility.swift
//  Den
//
//  Created by Garrett Johnson on 11/12/21.
//  Copyright © 2021 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import CoreData
import OSLog
import SwiftUI

struct HistoryUtility {
    static func markItemRead(item: Item) async {
        guard item.read != true else { return }
        await logHistory(items: [item])

        DispatchQueue.main.async {
            item.feedData?.feed?.page?.objectWillChange.send()
        }
    }

    static func toggleReadUnread(items: [Item]) async {
        if items.unread().isEmpty == true {
            await clearHistory(items: items)
        } else {
            await logHistory(items: items.unread())
        }
    }

    static func logHistory(items: [Item]) async {
        guard let profileObjectID = items.first?.feedData?.feed?.page?.profile?.objectID else { return }
        let itemObjectIDs = items.map { $0.objectID }

        await PersistenceController.shared.container.performBackgroundTask { context in
            guard let profile = context.object(with: profileObjectID) as? Profile else { return }

            for itemObjectID in itemObjectIDs {
                guard let item = context.object(with: itemObjectID) as? Item else { continue }
                let history = History.create(in: context, profile: profile)
                history.link = item.link
                history.visited = .now
                item.read = true
            }

            do {
                try context.save()
            } catch {
                CrashUtility.handleCriticalError(error as NSError)
            }
        }
    }

    static func clearHistory(items: [Item]) async {
        let itemObjectIDs = items.map { $0.objectID }
        let container = PersistenceController.shared.container

        await container.performBackgroundTask { context in
            for itemObjectID in itemObjectIDs {
                guard let item = context.object(with: itemObjectID) as? Item else { continue }
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

    static func removeExpired(context: NSManagedObjectContext, profile: Profile) throws {
        if profile.historyRetention == 0 {
            Logger.main.info("""
            History cleanup skipped for profile: \(profile.wrappedName). \
            Retention period is unlimited
            """)
            return
        }

        let historyRetentionStart = Date() - Double(profile.historyRetention) * 24 * 60 * 60
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "History")
        fetchRequest.predicate = NSCompoundPredicate(type: .and, subpredicates: [
            NSPredicate(
                format: "%K < %@",
                #keyPath(History.visited),
                historyRetentionStart as NSDate
            ),
            NSPredicate(format: "%K = %@", #keyPath(History.profile), profile)
        ])

        // Create a batch delete request for the fetch request
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)

        // Specify the result of the NSBatchDeleteRequest
        // should be the NSManagedObject IDs for the deleted objects
        deleteRequest.resultType = .resultTypeObjectIDs

        // Perform the batch delete
        let batchDelete = try? context.execute(deleteRequest) as? NSBatchDeleteResult

        guard let deleteResult = batchDelete?.result as? [NSManagedObjectID] else { return }

        let deletedObjects: [AnyHashable: Any] = [NSDeletedObjectsKey: deleteResult]

        // Merge the delete changes into the managed object context
        NSManagedObjectContext.mergeChanges(
            fromRemoteContextSave: deletedObjects,
            into: [context]
        )
        Logger.main.info("History cleanup finished")
    }
}
