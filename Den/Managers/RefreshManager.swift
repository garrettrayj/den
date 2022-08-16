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
    private let persistentContainer: NSPersistentContainer
    private let crashManager: CrashManager
    private let queue = OperationQueue()

    var refreshing: Bool = false

    init(persistentContainer: NSPersistentContainer, crashManager: CrashManager) {
        self.persistentContainer = persistentContainer
        self.crashManager = crashManager

        queue.qualityOfService = .userInitiated
        queue.maxConcurrentOperationCount = 20
    }

    public func cancel() {
        queue.cancelAllOperations()
    }

    public func refresh(profile: Profile) {
        var operations: [Operation] = []

        refreshing = true
        NotificationCenter.default.post(name: .refreshStarted, object: profile.objectID)

        let profileCompletionOp = BlockOperation { [
            weak profile,
            weak persistentContainer,
            weak crashManager
        ] in
            DispatchQueue.main.async {
                do {
                    try persistentContainer?.viewContext.save()
                } catch {
                    crashManager?.handleCriticalError(error as NSError)
                }

                self.refreshing = false
                NotificationCenter.default.post(name: .refreshFinished, object: profile?.objectID)

            }
        }
        operations.append(profileCompletionOp)

        let pagesCompletedOp = BlockOperation { [weak profile] in
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: .profileRefreshed, object: profile?.objectID)
            }
        }
        operations.append(pagesCompletedOp)

        // Trends analysis
        let trendsOp = TrendsOperation(
            persistentContainer: self.persistentContainer,
            profileObjectID: profile.objectID
        )
        operations.append(trendsOp)
        trendsOp.addDependency(pagesCompletedOp)
        profileCompletionOp.addDependency(trendsOp)

        // Page refresh operations
        profile.pagesArray.forEach { page in
            let (pageOps, pageCompletionOp) = createPageOps(page: page)
            operations.append(contentsOf: pageOps)
            pagesCompletedOp.addDependency(pageCompletionOp)
        }

        queue.addOperations(operations, waitUntilFinished: false)
    }

    private func createPageOps(page: Page) -> ([Operation], Operation) {
        var pageOps: [Operation] = []
        var feedCompletionOps: [Operation] = []

        page.feedsArray.forEach { feed in
            guard
                let refreshPlan = createRefreshPlan(feed)
            else { return }

            // Feed progress and notifications
            let feedCompletionOp = BlockOperation { [weak feed] in
                DispatchQueue.main.async {
                    feed?.objectWillChange.send()
                    NotificationCenter.default.post(name: .feedRefreshed, object: feed?.objectID)
                }
            }
            feedCompletionOp.addDependency(refreshPlan.saveFeedOp!)
            pageOps.append(contentsOf: refreshPlan.getOps())
            pageOps.append(feedCompletionOp)
            feedCompletionOps.append(feedCompletionOp)
        }

        // Page progress and notifications
        let pageCompletionOp = BlockOperation { [weak page] in
            DispatchQueue.main.async {
                page?.objectWillChange.send()
                NotificationCenter.default.post(name: .pageRefreshed, object: page?.objectID)
            }
        }
        feedCompletionOps.forEach { operation in
            pageCompletionOp.addDependency(operation)
        }
        pageOps.append(pageCompletionOp)

        return (pageOps, pageCompletionOp)
    }

    private func createRefreshPlan(_ feed: Feed) -> RefreshPlan? {
        guard let feedData = checkFeedData(feed) else { return nil }

        let refreshPlan = RefreshPlan(
            feed: feed,
            feedData: feedData,
            persistentContainer: persistentContainer
        )

        // Fetch meta (favicon, etc.) on first refresh or if user cleared cache, then check for updates occasionally
        if feedData.metaFetched == nil || feedData.metaFetched! < Date(timeIntervalSinceNow: -30 * 24 * 60 * 60) {
            refreshPlan.fullUpdate = true
        }

        refreshPlan.configureOps()

        return refreshPlan
    }

    func refresh(feed: Feed) {
        guard let refreshPlan = self.createRefreshPlan(feed) else { return }

        // Feed progress and notifications
        let feedCompletionOp = BlockOperation { [weak feed] in
            DispatchQueue.main.async {
                feed?.objectWillChange.send()
                NotificationCenter.default.post(name: .feedRefreshed, object: feed?.objectID)
            }
        }
        feedCompletionOp.addDependency(refreshPlan.saveFeedOp!)

        var operations = refreshPlan.getOps()
        operations.append(feedCompletionOp)

        queue.addOperations(operations, waitUntilFinished: false)
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
