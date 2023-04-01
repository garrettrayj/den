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

struct RefreshManager {
    static func refresh(profile: Profile) {
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

    static func refresh(
        profile: Profile,
        container: NSPersistentContainer = PersistenceController.shared.container,
        session: URLSession = URLSession.shared
    ) async {
        let maxConcurrency = min(4, ProcessInfo().activeProcessorCount)

        DispatchQueue.main.async {
            NotificationCenter.default.post(name: .refreshStarted, object: profile.objectID)
        }

        var feedUpdateTasks: [FeedUpdateTask] = []
        for feed in profile.feedsArray {
            if let url = feed.url {
                feedUpdateTasks.append(
                    FeedUpdateTask(
                        container: container,
                        feedObjectID: feed.objectID,
                        pageObjectID: feed.page?.objectID,
                        url: url,
                        updateMetadata: feed.needsMetaUpdate
                    )
                )
            }
        }

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

        await AnalyzeTask(container: container, profileObjectID: profile.objectID).execute()

        DispatchQueue.main.async {
            RefreshedDateStorage.shared.setRefreshed(profile, date: .now)
            NotificationCenter.default.post(name: .refreshFinished, object: profile.objectID)
        }
    }

    static func refresh(feed: Feed) async {
        let container = PersistenceController.shared.container

        if let url = feed.url {
            let feedUpdateTask = FeedUpdateTask(
                container: container,
                feedObjectID: feed.objectID,
                pageObjectID: feed.page?.objectID,
                url: url,
                updateMetadata: true
            )
            _ = await feedUpdateTask.execute()
        }
    }
}
