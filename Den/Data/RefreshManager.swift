//
//  RefreshManager.swift
//  Den
//
//  Created by Garrett Johnson on 4/1/23.
//  Copyright © 2023 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import CoreData
import OSLog

final class RefreshManager: ObservableObject {
    @Published var refreshing: Bool = false

    var progress: Progress = Progress()

    public func refresh(profile: Profile) {
        guard !refreshing else {
            Logger.main.info("Refresh already in progress")
            return
        }
        refreshing = true
        defer {
            refreshing = false
        }

        var ops: [Operation] = []

        let analyzeOperation = AnalyzeOperation(profileObjectID: profile.objectID)
        ops.append(analyzeOperation)

        for feed in profile.feedsArray {
            guard let url = feed.url else { continue }
            let op = FeedUpdateOperation(
                feedURL: url,
                feedObjectID: feed.objectID,
                updateMeta: feed.needsMetaUpdate
            )
            analyzeOperation.addDependency(op)
            ops.append(op)
        }

        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = min(4, ProcessInfo().activeProcessorCount)
        queue.addOperations(ops, waitUntilFinished: true)

        RefreshedDateStorage.shared.setRefreshed(profile, date: .now)
        profile.objectWillChange.send()
    }

    public func refresh(
        profile: Profile,
        session: URLSession = URLSession.shared
    ) async {
        guard !refreshing else {
            Logger.main.info("Refresh already in progress")
            return
        }
        DispatchQueue.main.async {
            self.refreshing = true
            NotificationCenter.default.post(name: .refreshStarted, object: profile.objectID)
        }
        defer {
            DispatchQueue.main.async {
                RefreshedDateStorage.shared.setRefreshed(profile, date: .now)
                NotificationCenter.default.post(name: .refreshFinished, object: profile.objectID)
                self.refreshing = false
            }
        }

        var feedUpdateTasks: [FeedUpdateTask] = []
        for feed in profile.feedsArray {
            if let url = feed.url {
                feedUpdateTasks.append(
                    FeedUpdateTask(
                        feedObjectID: feed.objectID,
                        pageObjectID: feed.page?.objectID,
                        url: url,
                        updateMetadata: feed.needsMetaUpdate
                    )
                )
            }
        }

        let maxConcurrency = min(4, ProcessInfo().activeProcessorCount)

        _ = await withTaskGroup(of: Void.self, returning: Void.self, body: { taskGroup in
                var working: Int = 0
                for task in feedUpdateTasks {
                    if working >= maxConcurrency {
                        await taskGroup.next()
                        working = 0
                    }
                    taskGroup.addTask { _ = await task.execute() }
                    working += 1
                }
                await taskGroup.waitForAll()
                DispatchQueue.main.async {
                    NotificationCenter.default.post(name: .pagesRefreshed, object: profile.objectID)
                }
            }
        )

        await AnalyzeTask(profileObjectID: profile.objectID).execute()
        await HistoryCleanupTask(profileObjectID: profile.objectID).execute()
    }

    func refresh(feed: Feed) async {
        if let url = feed.url {
            let feedUpdateTask = FeedUpdateTask(
                feedObjectID: feed.objectID,
                pageObjectID: feed.page?.objectID,
                url: url,
                updateMetadata: true
            )
            _ = await feedUpdateTask.execute()
        }
    }
}
