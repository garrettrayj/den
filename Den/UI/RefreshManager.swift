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
    @Published var refreshing = false
    @Published var progress = Progress()
    
    func refresh() async {
        let context = PersistenceController.shared.container.viewContext
        
        guard let feeds = try? context.fetch(Feed.fetchRequest()) as [Feed] else {
            return
        }
        
        await MainActor.run {
            progress.totalUnitCount = Int64(feeds.count)
            refreshing = true
        }

        await withTaskGroup(of: Void.self, returning: Void.self, body: { taskGroup in
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
                taskGroup.addTask {
                    await task.execute()
                    await MainActor.run {
                        self.progress.completedUnitCount += 1
                    }
                }
                working += 1
            }

            await taskGroup.waitForAll()
        })
        
        await MainActor.run {
            progress.completedUnitCount += 1
        }

        await AnalyzeTask().execute()

        UserDefaults.standard.set(Date().timeIntervalSince1970, forKey: "Refreshed")

        await MainActor.run {
            refreshing = false
            progress.completedUnitCount = 0
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
            feed.page?.objectWillChange.send()
        }
    }
}
