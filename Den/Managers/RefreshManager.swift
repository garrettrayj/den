//
//  RefreshManager.swift
//  Den
//
//  Created by Garrett Johnson on 8/16/20.
//  Copyright © 2020 Garrett Johnson. All rights reserved.
//

import CoreData
import OSLog

final class RefreshManager: ObservableObject {
    @Published public var refreshing: Bool = false

    let progress = Progress(totalUnitCount: 0)

    private var queue = OperationQueue()
    private var persistentContainer: NSPersistentContainer
    private var crashManager: CrashManager

    init(persistentContainer: NSPersistentContainer, crashManager: CrashManager) {
        self.persistentContainer = persistentContainer
        self.crashManager = crashManager
    }

    public func refresh(_ page: Page) {
        refreshing = true

        var operations: [Operation] = []

        page.feedsArray.forEach { feed in
            progress.totalUnitCount += 1
            operations.append(contentsOf: self.createFeedOps(feed))
        }

        DispatchQueue.global(qos: .userInitiated).async {
            self.queue.addOperations(operations, waitUntilFinished: true)
            DispatchQueue.main.async {
                self.refreshComplete(page: page)
            }
        }
    }

    public func refresh(_ feed: Feed) {
        refreshing = true
        progress.totalUnitCount += 1

        DispatchQueue.global(qos: .userInitiated).async {
            self.queue.addOperations(self.createFeedOps(feed), waitUntilFinished: true)
            DispatchQueue.main.async {
                self.refreshComplete(page: feed.page)
            }
        }
    }

    private func createFeedOps(_ feed: Feed) -> [Operation] {
        let feedData = self.checkFeedData(feed)
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

    private func checkFeedData(_ feed: Feed) -> FeedData {
        if feed.feedData == nil {
            let feed = FeedData.create(in: self.persistentContainer.viewContext, feedId: feed.id!)
            do {
                try self.persistentContainer.viewContext.save()
            } catch {
                DispatchQueue.main.async {
                    self.crashManager.handleCriticalError(error as NSError)
                }
            }

            return feed
        }

        return feed.feedData!
    }

    private func refreshComplete(page: Page?) {
        page?.objectWillChange.send()
        self.refreshing = false
        self.progress.totalUnitCount = 0
        self.progress.completedUnitCount = 0

        if persistentContainer.viewContext.hasChanges {
            do {
                try persistentContainer.viewContext.save()
            } catch {
                self.crashManager.handleCriticalError(error as NSError)
            }
        }
    }
}
