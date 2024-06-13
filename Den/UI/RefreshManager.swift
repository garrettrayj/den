//
//  RefreshManager.swift
//  Den
//
//  Created by Garrett Johnson on 4/1/23.
//  Copyright © 2023 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftData
import OSLog
import WidgetKit

@MainActor
@Observable final class RefreshManager {
    var refreshing = false
    var autoRefreshActive = false
    
    let progress = Progress()
    
    #if os(macOS)
    private var timer: Timer?
    
    func startAutoRefresh(interval: TimeInterval) {
        Logger.main.debug("Starting auto refresh with \(Int(interval)) second interval")
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { _ in
            Task {
                await self.refresh()
            }
        }
        autoRefreshActive = true
    }
    
    func stopAutoRefresh() {
        Logger.main.debug("Stopping auto refresh")
        timer?.invalidate()
        autoRefreshActive = false
    }
    #endif
    
    func refresh(inBackground: Bool = false) async {
        guard progress.totalUnitCount == 0 else { return }
        
        let maxConcurrency = min(4, ProcessInfo().activeProcessorCount)
        let context = ModelContext(DataController.shared.container)
        let request = FetchDescriptor<Page>(sortBy: [SortDescriptor(\Page.userOrder)])
        
        guard let pages = try? context.fetch(request) as [Page] else { return }
        let feedUpdates = pages.flatMap { $0.feedsArray }.compactMap { feed in
            return FeedUpdateTask(
                feedObjectID: feed.persistentModelID,
                url: feed.url!,
                updateMeta: feed.needsMetaUpdate
            )
        }
        
        progress.totalUnitCount = Int64(feedUpdates.count)
        
        if !inBackground {
            await MainActor.run { refreshing = true }
        }

        self.cleanupFeedData(context: context)

        await withTaskGroup(of: Void.self, returning: Void.self) { taskGroup in
            var working = 0
            for feedUpdate in feedUpdates {
                if working >= maxConcurrency {
                    await taskGroup.next()
                    working = 0
                }
                
                taskGroup.addTask {
                    await feedUpdate.execute()
                    self.progress.completedUnitCount += 1
                }
                working += 1
            }

            await taskGroup.waitForAll()
        }
        
        progress.completedUnitCount += 1

        await AnalyzeTask().execute()

        UserDefaults.standard.set(Date().timeIntervalSince1970, forKey: "Refreshed")
        WidgetCenter.shared.reloadAllTimelines()
        
        if !inBackground {
            await MainActor.run { refreshing = false }
        }
        
        progress.completedUnitCount = 0
        progress.totalUnitCount = 0
    }
    
    func refresh(feed: Feed) async {
        if let url = feed.url {
            let feedUpdateTask = FeedUpdateTask(
                feedObjectID: feed.persistentModelID,
                url: url,
                updateMeta: true
            )
            await feedUpdateTask.execute()
        }
    }
    
    private func cleanupFeedData(context: ModelContext) {
        guard let feedDatas = try? context.fetch(FetchDescriptor<FeedData>()) as [FeedData] else {
            Logger.main.error("Unable to fetch FeedData records for cleanup")
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
