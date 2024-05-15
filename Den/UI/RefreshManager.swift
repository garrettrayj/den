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

@Observable final class RefreshManager {
    var refreshing = false
    var progress = Progress()
    var autoRefreshActive = false
    
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
        guard !refreshing else { return }

        await MainActor.run { refreshing = true }
        
        var feedUpdates: [FeedUpdateTask] = []
        
        await PersistenceController.shared.container.performBackgroundTask { context in
            self.cleanupFeedData(context: context)
            
            let request = Page.fetchRequest()
            request.sortDescriptors = [NSSortDescriptor(keyPath: \Page.userOrder, ascending: true)]
            guard let pages = try? context.fetch(request) as [Page] else { return }
            
            feedUpdates = pages.flatMap { $0.feedsArray }.compactMap { feed in
                guard let url = feed.url else { return nil }
                return FeedUpdateTask(
                    feedObjectID: feed.objectID,
                    url: url,
                    updateMeta: feed.needsMetaUpdate
                )
            }
        }
        
        progress.totalUnitCount = Int64(feedUpdates.count)

        let maxConcurrency = min(3, ProcessInfo().activeProcessorCount)
        
        await withTaskGroup(of: Void.self, returning: Void.self, body: { taskGroup in
            for (index, feedUpdate) in feedUpdates.enumerated() {
                if index % maxConcurrency == 0 {
                    await taskGroup.next()
                }
                
                taskGroup.addTask {
                    await feedUpdate.execute()
                    self.progress.completedUnitCount += 1
                }
            }

            await taskGroup.waitForAll()
        })
        
        progress.completedUnitCount += 1
        await AnalyzeTask().execute()

        UserDefaults.group.set(Date().timeIntervalSince1970, forKey: "Refreshed")
        
        await MainActor.run { refreshing = false }
        progress.completedUnitCount = 0
        
        WidgetCenter.shared.reloadAllTimelines()
    }

    func refresh(feed: Feed) async {
        if let url = feed.url {
            let feedUpdateTask = FeedUpdateTask(
                feedObjectID: feed.objectID,
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
            do {
                try context.save()
                Logger.main.info("Purged \(orphansPurged) orphaned feed data records.")
            } catch {
                CrashUtility.handleCriticalError(error as NSError)
            }
        }
    }
}
