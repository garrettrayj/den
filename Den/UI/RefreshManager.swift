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
import WidgetKit
import Combine

final class RefreshManager: ObservableObject {
    @Published var refreshing = false
    @Published var progress = Progress()
    @Published var autoRefreshActive = false
    
    #if os(macOS)
    private let queue = OperationQueue()
    private var cancellable: Cancellable?
    
    func startAutoRefresh(interval: TimeInterval) {
        Logger.main.debug("Starting auto refresh with \(Int(interval)) second interval")

        cancellable?.cancel()

        cancellable = queue.schedule(
            after: .init(.now + interval),
            interval: .init(floatLiteral: interval),
            tolerance: .seconds(60)
        ) {
            Task {
                await self.refresh()
            }
        }
        
        autoRefreshActive = true
    }
    
    func stopAutoRefresh() {
        Logger.main.debug("Stopping auto refresh")

        cancellable?.cancel()

        autoRefreshActive = false
    }
    #endif
    
    func refresh() async {
        let context = PersistenceController.shared.container.viewContext
        
        cleanupFeedData(context: context)
        
        let request = Page.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Page.userOrder, ascending: true)]
        guard let pages = try? context.fetch(request) as [Page] else {
            return
        }
        let feeds = pages.flatMap { $0.feedsArray }

        await MainActor.run {
            progress.totalUnitCount = Int64(feeds.count)
            refreshing = true
        }

        await withTaskGroup(of: Void.self, returning: Void.self, body: { taskGroup in
            let maxConcurrency = min(3, ProcessInfo().activeProcessorCount)
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

        await MainActor.run {
            UserDefaults.group.set(Date().timeIntervalSince1970, forKey: "Refreshed")
            refreshing = false
            progress.completedUnitCount = 0
            WidgetCenter.shared.reloadAllTimelines()
        }
    }

    func refresh(feed: Feed) async {
        if let url = feed.url {
            let feedUpdateTask = FeedUpdateTask(
                feedObjectID: feed.objectID,
                pageObjectID: feed.page?.objectID,
                url: url,
                updateMeta: true
            )
            _ = await feedUpdateTask.execute()
        }
        
        await MainActor.run {
            feed.objectWillChange.send()
            feed.page?.objectWillChange.send()
        }
    }
    
    private func cleanupFeedData(context: NSManagedObjectContext) {
        guard let feedDatas = try? context.fetch(FeedData.fetchRequest()) as [FeedData] else {
            return
        }
        var orphansPurged = 0
        for feedData in feedDatas where feedData.feed == nil {
            context.delete(feedData)
            orphansPurged += 1
        }
        if orphansPurged > 0 {
            Logger.main.info("Purged \(orphansPurged) orphaned feed data records.")
        }
    }
}
