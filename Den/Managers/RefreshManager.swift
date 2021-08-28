//
//  RefreshManager.swift
//  Den
//
//  Created by Garrett Johnson on 8/16/20.
//  Copyright © 2020 Garrett Johnson. All rights reserved.
//

import CoreData
import OSLog
import SwiftUI

final class RefreshManager: ObservableObject {
    let queue = OperationQueue()

    private var persistentContainer: NSPersistentContainer
    private var crashManager: CrashManager

    init(persistentContainer: NSPersistentContainer, crashManager: CrashManager) {
        self.persistentContainer = persistentContainer
        self.crashManager = crashManager
    }

    public func refresh(
        page: Page,
        refreshing: Binding<Bool>,
        progress: Progress,
        callback: ((Page) -> Void)? = nil
    ) {
        refreshing.wrappedValue = true

        var operations: [Operation] = []

        page.feedsArray.forEach { feed in
            progress.totalUnitCount += 1
            operations.append(contentsOf: self.createFeedOps(feed, progress: progress))
        }

        DispatchQueue.global(qos: .userInitiated).async {
            self.queue.addOperations(operations, waitUntilFinished: true)
            DispatchQueue.main.async {
                self.refreshComplete(page: page, refreshing: refreshing, progress: progress)
                if let callback = callback {
                    callback(page)
                }
            }
        }
    }

    public func refresh(
        feed: Feed,
        callback: ((Feed) -> Void)? = nil
    ) {
        let operations = self.createFeedOps(feed)

        DispatchQueue.global(qos: .userInitiated).async {
            self.queue.addOperations(operations, waitUntilFinished: true)
            DispatchQueue.main.async {
                self.refreshComplete(page: feed.page)
                if let callback = callback {
                    callback(feed)
                }
            }
        }
    }

    private func createFeedOps(_ feed: Feed, progress: Progress? = nil) -> [Operation] {
        guard let feedData = checkFeedData(feed) else { return [] }

        let refreshPlan = RefreshPlan(
            feed: feed,
            feedData: feedData,
            persistentContainer: persistentContainer,
            crashManager: crashManager,
            progress: progress
        )

        // Fetch meta (favicon, etc.) on first refresh or if user cleared cache, then check for updates occasionally
        if feedData.metaFetched == nil || feedData.metaFetched! < Date(timeIntervalSinceNow: -30 * 24 * 60 * 60) {
            refreshPlan.fullUpdate = true
        }

        refreshPlan.configureOps()

        return refreshPlan.getOps()
    }

    private func checkFeedData(_ feed: Feed) -> FeedData? {
        if let feedData = feed.feedData {
            return feedData
        }

        guard let feedId = feed.id else { return nil }

        let feedData = FeedData.create(in: persistentContainer.viewContext, feedId: feedId)
        do {
            try persistentContainer.viewContext.save()
        } catch {
            crashManager.handleCriticalError(error as NSError)
        }

        return feedData
    }

    private func refreshComplete(page: Page?, refreshing: Binding<Bool>? = nil, progress: Progress? = nil) {
        page?.objectWillChange.send()
        page?.feedsArray.forEach({ feed in
            feed.objectWillChange.send()
        })

        if persistentContainer.viewContext.hasChanges {
            do {
                try persistentContainer.viewContext.save()
            } catch {
                self.crashManager.handleCriticalError(error as NSError)
            }
        }
        refreshing?.wrappedValue = false
        progress?.totalUnitCount = 0
        progress?.completedUnitCount = 0
    }
}
