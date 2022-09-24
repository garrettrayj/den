//
//  SyncManager.swift
//  Den
//
//  Created by Garrett Johnson on 11/12/21.
//  Copyright © 2021 Garrett Johnson. All rights reserved.
//

import CoreData
import SwiftUI
import SafariServices
import OSLog

struct SyncManager {
    static func openLink(
        context: NSManagedObjectContext,
        url: URL?,
        logHistoryItem: Item? = nil,
        readerMode: Bool = false
    ) {
        guard let url = url else { return }
        let config = SFSafariViewController.Configuration()
        config.entersReaderIfAvailable = readerMode

        let safariViewController = SFSafariViewController(url: url, configuration: config)

        guard
            let window = WindowFinder.current(),
            let rootViewController = window.rootViewController else { return }
        rootViewController.modalPresentationStyle = .fullScreen
        rootViewController.present(safariViewController, animated: true)

        if let historyItem = logHistoryItem {
            markItemRead(context: context, item: historyItem)
        }
    }

    static func markItemRead(context: NSManagedObjectContext, item: Item) {
        guard item.read != true else { return }
        item.read = true
        logHistory(context: context, items: [item])
        saveContext(context: context)
        NotificationCenter.default.postItemStatus(
            read: true,
            itemObjectID: item.objectID,
            feedObjectID: item.feedData?.feed?.objectID,
            pageObjectID: item.feedData?.feed?.page?.objectID,
            profileObjectID: item.feedData?.feed?.page?.profile?.objectID
        )
    }

    static func markItemUnread(context: NSManagedObjectContext, item: Item) {
        guard item.read != false else { return }
        item.read = false
        clearHistory(context: context, items: [item])
        saveContext(context: context)
        NotificationCenter.default.postItemStatus(
            read: false,
            itemObjectID: item.objectID,
            feedObjectID: item.feedData?.feed?.objectID,
            pageObjectID: item.feedData?.feed?.page?.objectID,
            profileObjectID: item.feedData?.feed?.page?.profile?.objectID
        )
    }

    static func toggleReadUnread(context: NSManagedObjectContext, items: [Item]) {
        var modItems: [Item]

        if items.unread().isEmpty == true {
            modItems = items.read()
            clearHistory(context: context, items: modItems)
        } else {
            modItems = items.unread()
            logHistory(context: context, items: modItems)
        }

        do {
            try context.save()
            modItems.forEach { item in
                NotificationCenter.default.postItemStatus(
                    read: item.read,
                    itemObjectID: item.objectID,
                    feedObjectID: item.feedData?.feed?.objectID,
                    pageObjectID: item.feedData?.feed?.page?.objectID,
                    profileObjectID: item.feedData?.feed?.page?.profile?.objectID
                )
            }
        } catch {
            CrashManager.handleCriticalError(error as NSError)
        }
    }

    static func logHistory(context: NSManagedObjectContext, items: [Item]) {
        guard let profile = items.first?.feedData?.feed?.page?.profile else { return }
        for item in items {
            item.read = true

            let history = item.history.first ?? History.create(in: context, profile: profile)
            history.link = item.link
            history.title = item.title
            history.visited = .now
        }
    }

    static func clearHistory(context: NSManagedObjectContext, items: [Item]) {
        guard let profile = items.first?.feedData?.feed?.page?.profile else { return }

        let profilePredicate = NSPredicate(
            format: "profile.id == %@",
            profile.id?.uuidString ?? ""
        )
        let linkPredicate = NSPredicate(
            format: "link IN %@",
            items.map { $0.link }
        )
        let compoundPredicate = NSCompoundPredicate(
            type: .and,
            subpredicates: [profilePredicate, linkPredicate]
        )

        // Specify a batch to delete with a fetch request
        let fetchRequest: NSFetchRequest<NSFetchRequestResult>
        fetchRequest = NSFetchRequest(entityName: "History")
        fetchRequest.predicate = compoundPredicate

        // Create a batch delete request for the fetch request
        let deleteRequest = NSBatchDeleteRequest(
            fetchRequest: fetchRequest
        )

        // Specify the result of the NSBatchDeleteRequest
        // should be the NSManagedObject IDs for the deleted objects
        deleteRequest.resultType = .resultTypeObjectIDs

        // Perform the batch delete
        let batchDelete = try? context.execute(deleteRequest)
            as? NSBatchDeleteResult

        guard let deleteResult = batchDelete?.result
            as? [NSManagedObjectID]
            else { return }

        let deletedObjects: [AnyHashable: Any] = [
            NSDeletedObjectsKey: deleteResult
        ]

        // Merge the delete changes into the managed object context
        NSManagedObjectContext.mergeChanges(
            fromRemoteContextSave: deletedObjects,
            into: [context]
        )

        // Update items
        items.forEach { item in
            item.read = false
        }
    }

    static func saveContext(context: NSManagedObjectContext) {
        do {
            if context.hasChanges {
                Logger.main.debug("Saving sync manager context changes")
                try context.save()
            }
        } catch {
            CrashManager.handleCriticalError(error as NSError)
        }
    }

}
