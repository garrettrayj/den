//
//  RefreshManager.swift
//  Den
//
//  Created by Garrett Johnson on 11/12/21.
//  Copyright © 2021 Garrett Johnson. All rights reserved.
//

import Foundation
import CoreData

struct RefreshManager {
    static var queue = OperationQueue()

    static func cancel() {
        queue.cancelAllOperations()
    }

    static func refresh(container: NSPersistentContainer, profile: Profile) {
        queue.maxConcurrentOperationCount = 8
        var operations: [Operation] = []

        NotificationCenter.default.post(name: .refreshStarted, object: profile.objectID)

        let profileCompletionOp = BlockOperation { [
            weak profile,
            weak container
        ] in
            DispatchQueue.main.async {
                do {
                    try container?.viewContext.save()
                } catch {
                    CrashManager.handleCriticalError(error as NSError)
                }
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
            persistentContainer: container,
            profileObjectID: profile.objectID
        )
        operations.append(trendsOp)
        trendsOp.addDependency(pagesCompletedOp)
        profileCompletionOp.addDependency(trendsOp)

        // Page refresh operations
        profile.pagesArray.forEach { page in
            let (pageOps, pageCompletionOp) = createPageOps(container: container, page: page)
            operations.append(contentsOf: pageOps)
            pagesCompletedOp.addDependency(pageCompletionOp)
        }

        queue.addOperations(operations, waitUntilFinished: false)
    }

    static func createPageOps(
        container: NSPersistentContainer,
        page: Page
    ) -> ([Operation], Operation) {
        var pageOps: [Operation] = []
        var feedCompletionOps: [Operation] = []

        page.feedsArray.forEach { feed in
            guard
                let refreshPlan = createRefreshPlan(container: container, feed: feed)
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

    static func createRefreshPlan(container: NSPersistentContainer, feed: Feed) -> RefreshPlan? {
        guard let feedData = checkFeedData(
            context: container.viewContext,
            feed: feed
        ) else { return nil }

        let refreshPlan = RefreshPlan(
            feed: feed,
            feedData: feedData,
            persistentContainer: container
        )

        // Fetch meta (favicon, etc.) on first refresh or if user cleared cache, then check for updates occasionally
        if feedData.metaFetched == nil || feedData.metaFetched! < Date(timeIntervalSinceNow: -30 * 24 * 60 * 60) {
            refreshPlan.fullUpdate = true
        }

        refreshPlan.configureOps()

        return refreshPlan
    }

    static func refresh(container: NSPersistentContainer, feed: Feed) {
        queue.maxConcurrentOperationCount = 2
        guard let refreshPlan = self.createRefreshPlan(
            container: container,
            feed: feed
        ) else { return }

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

    static func checkFeedData(context: NSManagedObjectContext, feed: Feed) -> FeedData? {
        if let feedData = feed.feedData {
            return feedData
        }

        guard let feedId = feed.id else { return nil }

        let feedData = FeedData.create(in: context, feedId: feedId)
        do {
            try context.save()
        } catch {
            CrashManager.handleCriticalError(error as NSError)
        }

        return feedData
    }
}
