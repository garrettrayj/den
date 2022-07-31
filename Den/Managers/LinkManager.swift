//
//  LinkManager.swift
//  Den
//
//  Created by Garrett Johnson on 11/12/21.
//  Copyright © 2021 Garrett Johnson. All rights reserved.
//

import CoreData
import SwiftUI
import SafariServices

final class LinkManager: ObservableObject {
    // Hosting window set in app lifecycle
    var window: UIWindow?

    let viewContext: NSManagedObjectContext
    let crashManager: CrashManager
    let profileManager: ProfileManager

    init(
        viewContext: NSManagedObjectContext,
        crashManager: CrashManager,
        profileManager: ProfileManager
    ) {
        self.viewContext = viewContext
        self.crashManager = crashManager
        self.profileManager = profileManager
    }

    public func openLink(url: URL?, logHistoryItem: Item? = nil, readerMode: Bool = false) {
        guard let url = url else { return }

        if let historyItem = logHistoryItem {
            // True reads are logged with a visited date
            logHistory(item: historyItem, visisted: Date())
            saveContext()
        }

        let config = SFSafariViewController.Configuration()
        config.entersReaderIfAvailable = readerMode

        let safariViewController = SFSafariViewController(url: url, configuration: config)

        guard let rootViewController = window?.rootViewController else { return }
        rootViewController.modalPresentationStyle = .fullScreen
        rootViewController.present(safariViewController, animated: true)
    }

    public func toggleItemRead(item: Item) {
        if item.read {
            markItemUnread(item: item)
        } else {
            markItemRead(item: item)
        }
    }

    public func markItemRead(item: Item) {
        logHistory(item: item)
        saveContext()
    }

    public func markItemUnread(item: Item) {
        item.history?.forEach { history in
            viewContext.delete(history)
        }
        saveContext()
    }

    public func toggleReadUnread(feed: Feed) {
        let allItemsRead: Bool = feed.feedData?.previewItems.unread().isEmpty == true
        if allItemsRead {
            feed.feedData?.previewItems.read().forEach { item in
                clearHistory(item: item)
            }
        } else {
            feed.feedData?.previewItems.unread().forEach { item in
                logHistory(item: item)
            }
        }
        saveContext()
    }

    public func toggleReadUnread(page: Page) {
        if page.previewItems.unread().isEmpty == true {
            page.previewItems.read().forEach { item in
                clearHistory(item: item)
            }
        } else {
            page.previewItems.unread().forEach { item in
                logHistory(item: item)
            }
        }
        saveContext()
    }

    public func toggleReadUnread(profile: Profile) {
        let allItemsRead: Bool = profile.previewItems.unread().isEmpty == true
        if allItemsRead {
            profile.previewItems.read().forEach { item in
                clearHistory(item: item)
            }
        } else {
            profile.previewItems.unread().forEach { item in
                logHistory(item: item)
            }
        }
        saveContext()
    }

    public func toggleReadUnread(trend: Trend) {
        if trend.items.unread().isEmpty {
            trend.items.forEach { item in
                clearHistory(item: item)
            }
        } else {
            trend.items.unread().forEach { item in
                logHistory(item: item)
            }
        }
        saveContext()
    }

    private func logHistory(item: Item, visisted: Date? = nil) {
        guard let activeProfile = profileManager.activeProfile else {
            return
        }

        let history = item.history?.first ?? History.create(in: viewContext, profile: activeProfile)
        history.link = item.link
        history.title = item.title

        if visisted != nil {
            history.visited = visisted
        }
        item.objectWillChange.send()
        NotificationCenter.default.post(name: .itemRead, object: item.feedData?.feed?.page?.objectID)
    }

    private func clearHistory(item: Item) {
        item.history?.forEach { history in
            viewContext.delete(history)
        }
        item.objectWillChange.send()
        NotificationCenter.default.post(name: .itemUnread, object: item.feedData?.feed?.page?.objectID)
    }

    private func saveContext() {
        if viewContext.hasChanges {
            do {
                try viewContext.save()
            } catch {
                crashManager.handleCriticalError(error as NSError)
            }
        }
    }
}
