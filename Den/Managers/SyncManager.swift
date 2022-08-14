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

final class SyncManager: ObservableObject {
    private let persistentContainer: NSPersistentContainer
    private let viewContext: NSManagedObjectContext
    private let crashManager: CrashManager
    private let profileManager: ProfileManager
    private var historySynced: Date?
    private var historyCleaned: Date?
    private var dataCleaned: Date?

    // Hosting window set in app lifecycle
    public var window: UIWindow?

    init(
        persistentContainer: NSPersistentContainer,
        crashManager: CrashManager,
        profileManager: ProfileManager
    ) {
        self.persistentContainer = persistentContainer
        self.crashManager = crashManager
        self.profileManager = profileManager

        viewContext = persistentContainer.viewContext
    }

    public func openLink(url: URL?, logHistoryItem: Item? = nil, readerMode: Bool = false) {
        guard let url = url else { return }

        if let historyItem = logHistoryItem {
            markItemRead(item: historyItem)
        }

        let config = SFSafariViewController.Configuration()
        config.entersReaderIfAvailable = readerMode

        let safariViewController = SFSafariViewController(url: url, configuration: config)

        guard let rootViewController = window?.rootViewController else { return }
        rootViewController.modalPresentationStyle = .fullScreen
        rootViewController.present(safariViewController, animated: true)
    }

    public func markItemRead(item: Item) {
        guard let profile = profileManager.activeProfile else { return }
        item.read = true
        logHistory(profile: profile, items: [item])
        saveContext()
        NotificationCenter.default.postItemStatus(
            read: true,
            itemObjectID: item.objectID,
            feedObjectID: item.feedData?.feed?.objectID,
            pageObjectID: item.feedData?.feed?.page?.objectID,
            profileObjectID: item.feedData?.feed?.page?.profile?.objectID
        )
    }

    public func markItemUnread(item: Item) {
        item.read = false
        clearHistory(items: [item])
        saveContext()

        NotificationCenter.default.postItemStatus(
            read: false,
            itemObjectID: item.objectID,
            feedObjectID: item.feedData?.feed?.objectID,
            pageObjectID: item.feedData?.feed?.page?.objectID,
            profileObjectID: item.feedData?.feed?.page?.profile?.objectID
        )
    }

    public func toggleReadUnread(items: [Item]) {
        if items.unread().isEmpty == true {
            let readItems = items.read()
            clearHistory(items: readItems)
            readItems.forEach { item in
                item.read = false
            }
            saveContext()
            readItems.forEach { item in
                NotificationCenter.default.postItemStatus(
                    read: false,
                    itemObjectID: item.objectID,
                    feedObjectID: item.feedData?.feed?.objectID,
                    pageObjectID: item.feedData?.feed?.page?.objectID,
                    profileObjectID: item.feedData?.feed?.page?.profile?.objectID
                )
            }
        } else {
            guard let profile = profileManager.activeProfile else { return }
            let unreadItems = items.unread()
            logHistory(profile: profile, items: unreadItems)
            unreadItems.forEach { item in
                item.read = true
            }
            saveContext()
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

    private func logHistory(
        profile: Profile,
        items: [Item]
    ) {
        for item in items {
            let history = item.history.first ?? History.create(in: viewContext, profile: profile)
            history.link = item.link
            history.title = item.title
            history.visited = .now
        }
    }

    private func clearHistory(items: [Item]) {
        for item in items {
            item.history.forEach { history in
                viewContext.delete(history)
            }
        }
    }

    private func saveContext() {
        do {
            if viewContext.hasChanges {
                Logger.main.info("Saving sync manager context changes")
                try viewContext.save()
            }
        } catch {
            crashManager.handleCriticalError(error as NSError)
        }
    }

    func updateLocalHistory() {
        do {
            let items = try viewContext.fetch(Item.fetchRequest()) as [Item]
            items.forEach { item in
                item.read = item.history.isEmpty == false
            }
            if viewContext.hasChanges {
                try viewContext.save()
            }
            historySynced = Date.now
            Logger.main.info("History synchronized for \(items.count) items")
        } catch {
            self.crashManager.handleCriticalError(error as NSError)
        }
    }

    public func syncHistory() {
        if historySynced != nil && historySynced! > Date.now - 60 * 5 {
            Logger.main.debug("Skipping history synchronization")
            return
        }

        updateLocalHistory()
    }

    public func cleanupHistory() {
        if historyCleaned != nil && historyCleaned! > Date.now - 60 * 60 * 24 {
            Logger.main.debug("Skipping history cleanup")
            return
        }

        do {
            var itemsRemoved: Int = 0
            let profiles = try viewContext.fetch(Profile.fetchRequest()) as [Profile]
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

                let fetchResults = try viewContext.fetch(fetchRequest) as? [History]
                fetchResults?.forEach { viewContext.delete($0) }
                itemsRemoved += fetchResults?.count ?? 0
            }

            if viewContext.hasChanges {
                try viewContext.save()
            }

            historyCleaned = Date.now
            Logger.main.info("History cleanup finished. \(itemsRemoved) entries removed")
        } catch {
            crashManager.handleCriticalError(error as NSError)
        }
    }

    /**
     Remove abandoned FeedData entities. Related Item entities will also be removed via cascade.
     */
    public func cleanupData() {
        if dataCleaned != nil && dataCleaned! > Date.now - 60 * 60 * 24 {
            Logger.main.debug("Skipping data cleanup")
            return
        }

        do {
            let feedDatas = try viewContext.fetch(FeedData.fetchRequest()) as [FeedData]
            let orphanedFeedDatas = feedDatas.filter { $0.feed == nil }
            if orphanedFeedDatas.isEmpty {
                Logger.main.info("Skipping feed data cleanup. No orphans found")
                return
            }
            for feedData in orphanedFeedDatas where feedData.feed == nil {
                viewContext.delete(feedData)
            }
            if viewContext.hasChanges {
                try viewContext.save()
                Logger.main.info("Purged \(orphanedFeedDatas.count) orphan feed data cache(s)")
            }
            dataCleaned = Date.now
        } catch {
            crashManager.handleCriticalError(error as NSError)
        }
    }
}
