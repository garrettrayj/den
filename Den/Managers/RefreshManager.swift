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
    let persistentContainer: NSPersistentContainer
    let crashManager: CrashManager

    init(persistentContainer: NSPersistentContainer, crashManager: CrashManager) {
        self.persistentContainer = persistentContainer
        self.crashManager = crashManager

        queue.qualityOfService = .userInitiated
        queue.maxConcurrentOperationCount = 8
    }

    public func cancel() {
        queue.cancelAllOperations()
    }

    public func refresh(viewModel: ProfileViewModel, activePage: Page?) {
        let profile = viewModel.profile
        var operations: [Operation] = []

        if viewModel.refreshing {
            return
        }

        viewModel.refreshing = true
        viewModel.refreshProgress.totalUnitCount = Int64(profile.feedCount)
        viewModel.refreshProgress.completedUnitCount = 0

        let profileCompletionOp = BlockOperation { [weak viewModel] in
            DispatchQueue.main.async {
                viewModel?.refreshing = false
            }
        }
        operations.append(profileCompletionOp)

        if let activePage = activePage {
            operations.append(contentsOf:
                createPageOps(
                    page: activePage,
                    profileViewModel: viewModel,
                    profileCompletionOp: profileCompletionOp
                )
            )
        }

        profile.pagesArray.forEach { page in
            if page == activePage { return }

            let pageOps = createPageOps(
                page: page,
                profileViewModel: viewModel,
                profileCompletionOp: profileCompletionOp
            )
            operations.append(contentsOf: pageOps)
        }

        queue.addOperations(operations, waitUntilFinished: false)
    }

    private func createPageOps(
        page: Page,
        profileViewModel: ProfileViewModel,
        profileCompletionOp: Operation
    ) -> [Operation] {
        var pageOps: [Operation] = []
        var feedCompletionOps: [Operation] = []

        page.feedsArray.forEach { feed in
            guard
                let refreshPlan = createRefreshPlan(feed)
            else { return }

            // Feed progress and notifications
            let feedCompletionOp = BlockOperation { [weak feed] in
                DispatchQueue.main.async {
                    profileViewModel.refreshProgress.completedUnitCount += 1
                    feed?.objectWillChange.send()
                    feed?.page?.objectWillChange.send()
                    guard let objectID = feed?.objectID else { return }
                    NotificationCenter.default.post(name: .feedRefreshed, object: objectID)
                }
            }
            feedCompletionOp.addDependency(refreshPlan.saveFeedOp!)
            pageOps.append(contentsOf: refreshPlan.getOps())
            pageOps.append(feedCompletionOp)
            feedCompletionOps.append(feedCompletionOp)
            NotificationCenter.default.post(name: .feedQueued, object: feed.objectID)
        }

        // Page progress and notifications
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

        return pageOps
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
                feed?.page?.objectWillChange.send()
                guard let objectID = feed?.objectID else { return }
                NotificationCenter.default.post(name: .feedRefreshed, object: objectID)
            }
        }
        feedCompletionOp.addDependency(refreshPlan.saveFeedOp!)

        var operations = refreshPlan.getOps()
        operations.append(feedCompletionOp)

        NotificationCenter.default.post(name: .feedQueued, object: feed.objectID)
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
