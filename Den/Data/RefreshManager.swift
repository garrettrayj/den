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

final class RefreshManager {
    static func refresh() async {
        await MainActor.run {
            NotificationCenter.default.post(name: .refreshStarted, object: nil)
        }

        await withTaskGroup(of: Void.self, returning: Void.self, body: { taskGroup in
            let context = PersistenceController.shared.container.viewContext
            guard let feeds = try? context.fetch(Feed.fetchRequest()) as [Feed] else {
                return
            }
            
            let maxConcurrency = min(4, ProcessInfo().activeProcessorCount)
            let feedUpdateTasks: [FeedUpdateTask] = feeds.compactMap { feed in
                guard let url = feed.url else { return nil }
                return FeedUpdateTask(
                    feedObjectID: feed.objectID,
                    pageObjectID: feed.page?.objectID,
                    url: url,
                    updateMeta: feed.needsMetaUpdate
                )
            }
            
            var working: Int = 0
            for task in feedUpdateTasks {
                if working >= maxConcurrency {
                    await taskGroup.next()
                    working = 0
                }
                taskGroup.addTask { await task.execute() }
                working += 1
            }

            await taskGroup.waitForAll()
        })
        
        await MainActor.run {
            NotificationCenter.default.post(name: .refreshProgressed, object: nil)
        }
    
        await AnalyzeTask().execute()

        RefreshedDateStorage.setRefreshed(date: .now)

        await MainActor.run {
            NotificationCenter.default.post(name: .refreshFinished, object: nil)
        }
    }

    static func refresh(feed: Feed) async {
        if let url = feed.url {
            let feedUpdateTask = FeedUpdateTask(
                feedObjectID: feed.objectID,
                pageObjectID: feed.page?.objectID,
                url: url,
                updateMeta: true
            )
            _ = await feedUpdateTask.execute()
        }
        
        DispatchQueue.main.async {
            feed.objectWillChange.send()
        }
    }
}
