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
    private let bgContext: NSManagedObjectContext
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

        bgContext = persistentContainer.newBackgroundContext()
        bgContext.undoManager = nil
        bgContext.automaticallyMergesChangesFromParent = true
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
        guard let profileObjectID = profileManager.activeProfile?.objectID else { return }
        item.read = true
        logHistory(profileObjectID: profileObjectID, itemObjectIDs: [item.objectID])
        NotificationCenter.default.post(name: .itemRead, object: item.objectID)
    }

    public func markItemUnread(item: Item) {
        item.read = false
        clearHistory(itemObjectIDs: [item.objectID])
        NotificationCenter.default.post(name: .itemUnread, object: item.objectID)
    }

    public func toggleReadUnread(items: [Item]) {
        let allItemsRead: Bool = items.unread().isEmpty == true
        if allItemsRead {
            let readItems = items.read()
            clearHistory(itemObjectIDs: readItems.map { $0.objectID })
            readItems.forEach { $0.read = false }
        } else {
            guard let profileObjectID = profileManager.activeProfile?.objectID else { return }
            let unreadItems = items.unread()
            logHistory(profileObjectID: profileObjectID, itemObjectIDs: unreadItems.map { $0.objectID })
            unreadItems.forEach { $0.read = true }
        }
    }

    private func logHistory(
        profileObjectID: NSManagedObjectID,
        itemObjectIDs: [NSManagedObjectID]
    ) {
        guard let profile = bgContext.object(with: profileObjectID) as? Profile else { return }

        for itemObjectID in itemObjectIDs {
            guard
                let item = bgContext.object(with: itemObjectID) as? Item
            else { continue }

            let history = item.history?.first ?? History.create(in: bgContext, profile: profile)
            history.link = item.link
            history.title = item.title
            history.visited = .now
        }
    }

    private func clearHistory(itemObjectIDs: [NSManagedObjectID]) {
        for itemObjectID in itemObjectIDs {
            guard
                let item = bgContext.object(with: itemObjectID) as? Item
            else { continue }

            item.history?.forEach { history in
                bgContext.delete(history)
            }
        }
    }

    public func saveContext() {
        do {
            if bgContext.hasChanges {
                Logger.main.info("Saving sync manager context changes")
                try bgContext.save()
            }
        } catch {
            crashManager.handleCriticalError(error as NSError)
        }
    }

    public func syncHistory() {
        do {
            if historySynced == nil || historySynced! < Date.now - 60 * 1 {
                let items = try bgContext.fetch(Item.fetchRequest()) as [Item]
                Logger.main.info("Syncing history for \(items.count) items")

                for item in items {
                    item.read = item.history?.isEmpty == false
                }
            }

            if bgContext.hasChanges {
                try bgContext.save()
            }

            historySynced = Date.now
        } catch {
            crashManager.handleCriticalError(error as NSError)
        }
    }

    public func cleanupHistory() {
        if historyCleaned == nil || historyCleaned! > Date.now - 60 * 2 {
            return
        }

        do {
            let profiles = try bgContext.fetch(Profile.fetchRequest()) as [Profile]
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

                let fetchResults = try bgContext.fetch(fetchRequest) as? [History]
                fetchResults?.forEach { bgContext.delete($0) }
            }

            if bgContext.hasChanges {
                try bgContext.save()
            }

            historyCleaned = Date.now
        } catch {
            crashManager.handleCriticalError(error as NSError)
        }
    }

    /**
     Remove abandoned FeedData entities. Related Item entities will also be removed via cascade.
     */
    public func cleanupData() {
        if dataCleaned == nil || dataCleaned! > Date.now - 60 * 2 {
            return
        }

        do {
            let feedDatas = try bgContext.fetch(FeedData.fetchRequest()) as [FeedData]
            let orphanedFeedDatas = feedDatas.filter { $0.feed == nil }
            if orphanedFeedDatas.count == 0 {
                Logger.main.info("No orphaned feed data caches found")
                return
            }
            Logger.main.info("Purging \(orphanedFeedDatas.count) orphaned feed data cache(s)")
            for feedData in orphanedFeedDatas where feedData.feed == nil {
                bgContext.delete(feedData)
            }

            if bgContext.hasChanges {
                try bgContext.save()
            }

            dataCleaned = Date.now
        } catch {
            crashManager.handleCriticalError(error as NSError)
        }
    }
}
