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
        page.feedsArray.forEach { feed in
            self.refresh(feed)
        }
    }

    public func refresh(_ feed: Feed) {
        refreshing = true
        progress.totalUnitCount += 1

        let feedData = self.checkFeedData(feed)

        let refreshPlan = RefreshPlan(
            feed: feed,
            feedData: feedData,
            persistentContainer: persistentContainer,
            crashManager: crashManager,
            progress: progress,
            completionCallback: { self.refreshFinished(page: feed.page) }
        )

        // Fetch meta (favicon, etc.) on first refresh or if user cleared cache, then check for updates occasionally
        if feedData.metaFetched == nil || feedData.metaFetched! < Date(timeIntervalSinceNow: -30 * 24 * 60 * 60) {
            refreshPlan.fullUpdate = true
        }

        refreshPlan.configureOps()

        DispatchQueue.global(qos: .userInitiated).async {
            self.queue.addOperations(refreshPlan.operations, waitUntilFinished: false)
        }
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

    private func refreshFinished(page: Page?) {
        if self.persistentContainer.viewContext.hasChanges {
            do {
                try self.persistentContainer.viewContext.save()
            } catch let error as NSError {
                self.crashManager.handleCriticalError(error)
            }
        }

        page?.objectWillChange.send()
        self.refreshing = false
    }
}
