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
    @Published var isRefreshing: Bool = false

    var queue = OperationQueue()

    private var persistentContainer: NSPersistentContainer
    private var crashManager: CrashManager

    init(persistentContainer: NSPersistentContainer, crashManager: CrashManager) {
        self.persistentContainer = persistentContainer
        self.crashManager = crashManager

        queue.maxConcurrentOperationCount = ProcessInfo.processInfo.processorCount
    }

    public func refresh(profile: Profile) {
        var operations: [Operation] = []

        NotificationCenter.default.post(name: .profileQueued, object: profile.objectID)

        let profileCompletionOp = BlockOperation { [weak profile] in
            DispatchQueue.main.async {
                guard let objectID = profile?.objectID else { return }
                NotificationCenter.default.post(name: .profileRefreshed, object: objectID)
            }
        }
        operations.append(profileCompletionOp)

        profile.pagesArray.forEach { page in
            var pageOps: [Operation] = []
            var feedCompletionOps: [Operation] = []
            page.feedsArray.forEach { feed in
                guard
                    let refreshPlan = createRefreshPlan(feed),
                    let feedCompletionOp = refreshPlan.completionOp
                else { return }

                pageOps.append(contentsOf: refreshPlan.getOps())
                feedCompletionOps.append(feedCompletionOp)

                NotificationCenter.default.post(name: .feedQueued, object: feed.objectID)
            }
            NotificationCenter.default.post(name: .pageQueued, object: page.objectID)
            let pageCompletionOp = BlockOperation { [weak page] in
                DispatchQueue.main.async {
                    guard let objectID = page?.objectID else { return }
                    NotificationCenter.default.post(name: .pageRefreshed, object: objectID)
                }
            }
            feedCompletionOps.forEach { operation in
                pageCompletionOp.addDependency(operation)
            }
            pageOps.append(pageCompletionOp)
            profileCompletionOp.addDependency(pageCompletionOp)
            operations.append(contentsOf: pageOps)
        }
        executeOperations(operations: operations)
    }

    public func refresh(page: Page) {
        var operations: [Operation] = []
        var feedCompletionOps: [Operation] = []

        page.feedsArray.forEach { feed in
            guard
                let refreshPlan = createRefreshPlan(feed),
                let feedCompletionOp = refreshPlan.completionOp
            else { return }

            operations.append(contentsOf: refreshPlan.getOps())
            feedCompletionOps.append(feedCompletionOp)

            NotificationCenter.default.post(name: .feedQueued, object: feed.objectID)
        }

        NotificationCenter.default.post(name: .pageQueued, object: page.objectID)
        let pageCompletionOp = BlockOperation { [weak page] in
            DispatchQueue.main.async {
                guard let objectID = page?.objectID else { return }
                NotificationCenter.default.post(name: .pageRefreshed, object: objectID)
            }
        }
        feedCompletionOps.forEach { operation in
            pageCompletionOp.addDependency(operation)
        }
        operations.append(pageCompletionOp)
        executeOperations(operations: operations)
    }

    func refresh(feed: Feed) {
        guard let operations = self.createRefreshPlan(feed)?.getOps() else { return }
        NotificationCenter.default.post(name: .feedQueued, object: feed.objectID)
        executeOperations(operations: operations)
    }

    func createRefreshPlan(_ feed: Feed) -> RefreshPlan? {
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

    private func executeOperations(operations: [Operation]) {
        isRefreshing = true
        queue.addOperations(operations, waitUntilFinished: false)
        queue.addBarrierBlock {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.isRefreshing = false
            }
        }
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
