//
//  RefreshManager.swift
//  Den
//
//  Created by Garrett Johnson on 11/12/21.
//  Copyright © 2021 Garrett Johnson. All rights reserved.
//

import Foundation
import CoreData

final class RefreshManager: ObservableObject {
    let queue = OperationQueue()

    private var persistentContainer: NSPersistentContainer
    private var crashManager: CrashManager

    private var currentPageViewModels: [PageViewModel] = []

    init(persistentContainer: NSPersistentContainer, crashManager: CrashManager) {
        self.persistentContainer = persistentContainer
        self.crashManager = crashManager

        queue.maxConcurrentOperationCount = 6
    }

    public func refresh(pageViewModel: PageViewModel) {
        pageViewModel.refreshState = .loading
        var operations: [Operation] = []

        pageViewModel.page.feedsArray.forEach { feed in
            pageViewModel.progress.totalUnitCount += 1
            operations.append(
                contentsOf: createFeedOps(feed, progress: pageViewModel.progress)
            )
        }

        DispatchQueue.global(qos: .userInitiated).async {
            self.queue.addOperations(operations, waitUntilFinished: true)
            DispatchQueue.main.async {
                pageViewModel.refreshState = .waiting
                pageViewModel.progress.completedUnitCount = 0
                pageViewModel.progress.totalUnitCount = 0
            }
        }
    }

    public func refresh(feedViewModel: FeedViewModel) {
        feedViewModel.refreshing = true
        let operations = self.createFeedOps(feedViewModel.feed)

        DispatchQueue.global(qos: .userInitiated).async {
            self.queue.addOperations(operations, waitUntilFinished: true)
            DispatchQueue.main.async {
                feedViewModel.refreshing = false
            }
        }
    }

    public func refresh(feed: Feed, callback: @escaping () -> Void) {
        DispatchQueue.global(qos: .userInitiated).async {
            let operations = self.createFeedOps(feed)
            self.queue.addOperations(operations, waitUntilFinished: true)
            DispatchQueue.main.async {
                callback()
            }
        }
    }

    func createFeedOps(_ feed: Feed, progress: Progress? = nil) -> [Operation] {
        guard let feedData = checkFeedData(feed) else { return [] }

        let refreshPlan = RefreshPlan(
            feed: feed,
            feedData: feedData,
            persistentContainer: persistentContainer,
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
            self.crashManager.handleCriticalError(error as NSError)
        }

        return feedData
    }
}
