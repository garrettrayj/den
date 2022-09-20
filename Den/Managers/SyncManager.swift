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
        logHistory(context: context, items: [item], visited: .now)
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
        if items.unread().isEmpty == true {
            let readItems = items.read()
            clearHistory(context: context, items: readItems)
            for item in readItems {
                item.read = false
                NotificationCenter.default.postItemStatus(
                    read: false,
                    itemObjectID: item.objectID,
                    feedObjectID: item.feedData?.feed?.objectID,
                    pageObjectID: item.feedData?.feed?.page?.objectID,
                    profileObjectID: item.feedData?.feed?.page?.profile?.objectID
                )
            }
            saveContext(context: context)
        } else {
            let unreadItems = items.unread()
            logHistory(context: context, items: unreadItems)
            unreadItems.forEach { item in
                item.read = true
            }
            saveContext(context: context)
            unreadItems.forEach { item in
                NotificationCenter.default.postItemStatus(
                    read: true,
                    itemObjectID: item.objectID,
                    feedObjectID: item.feedData?.feed?.objectID,
                    pageObjectID: item.feedData?.feed?.page?.objectID,
                    profileObjectID: item.feedData?.feed?.page?.profile?.objectID
                )
            }
        }
    }

    static func logHistory(context: NSManagedObjectContext, items: [Item], visited: Date? = nil) {
        guard let profile = items.first?.feedData?.feed?.page?.profile else { return }
        for item in items {
            let history = item.history.first ?? History.create(in: context, profile: profile)
            history.link = item.link
            history.title = item.title
            history.visited = visited
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

        // Create a batch delete request for the
        // fetch request
        let deleteRequest = NSBatchDeleteRequest(
            fetchRequest: fetchRequest
        )

        // Specify the result of the NSBatchDeleteRequest
        // should be the NSManagedObject IDs for the
        // deleted objects
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

        // Merge the delete changes into the managed
        // object context
        NSManagedObjectContext.mergeChanges(
            fromRemoteContextSave: deletedObjects,
            into: [context]
        )
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

    static func cleanupHistory(context: NSManagedObjectContext) {
        do {
            var itemsRemoved: Int = 0
            let profiles = try context.fetch(Profile.fetchRequest()) as [Profile]
            try profiles.forEach { profile in
                if profile.historyRetention == 0 { return }
                let historyRetentionStart = Date() - Double(profile.historyRetention) * 24 * 60 * 60
                let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "History")
                fetchRequest.predicate = NSPredicate(
                    format: "%K < %@",
                    #keyPath(History.visited),
                    historyRetentionStart as NSDate
                )
                fetchRequest.sortDescriptors = []

                let fetchResults = try context.fetch(fetchRequest) as? [History]
                fetchResults?.forEach { context.delete($0) }
                itemsRemoved += fetchResults?.count ?? 0
            }
            if context.hasChanges {
                try context.save()
            }
            Logger.main.info("History cleanup finished. \(itemsRemoved) entries removed")
        } catch {
            CrashManager.handleCriticalError(error as NSError)
        }
    }

    /**
     Remove abandoned FeedData entities. Related Item entities will also be removed via cascade.
     */
    static func cleanupData(context: NSManagedObjectContext) {
        do {
            let feedDatas = try context.fetch(FeedData.fetchRequest()) as [FeedData]
            let orphanedFeedDatas = feedDatas.filter { $0.feed == nil }
            if orphanedFeedDatas.isEmpty {
                Logger.main.info("Skipping feed data cleanup. No orphans found")
                return
            }
            for feedData in orphanedFeedDatas where feedData.feed == nil {
                context.delete(feedData)
            }
            if context.hasChanges {
                try context.save()
                Logger.main.info("Purged \(orphanedFeedDatas.count) orphan feed data cache(s)")
            }
        } catch {
            CrashManager.handleCriticalError(error as NSError)
        }
    }
}
