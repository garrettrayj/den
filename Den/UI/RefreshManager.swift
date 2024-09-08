//
//  RefreshManager.swift
//  Den
//
//  Created by Garrett Johnson on 4/1/23.
//  Copyright © 2023 Garrett Johnson. All rights reserved.
//

import Combine
import CoreData
import OSLog
import WidgetKit

@MainActor
final class RefreshManager: ObservableObject {
    struct FeedUpdateInfo {
        let objectID: NSManagedObjectID
        let url: URL
        let updateMeta: Bool
    }
    
    @Published var refreshing = false
    @Published var autoRefreshActive = false
    
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

        if !inBackground {
            await MainActor.run { refreshing = true }
        }
        
        let feedUpdates = updateInfoForAllFeeds()
        
        progress.totalUnitCount = Int64(feedUpdates.count)

        let maxConcurrency = min(3, ProcessInfo().activeProcessorCount)
        
        await withTaskGroup(of: Void.self, returning: Void.self) { taskGroup in
            var working = 0
            for feedUpdate in feedUpdates {
                if working >= maxConcurrency {
                    await taskGroup.next()
                    working = 0
                }
                
                taskGroup.addTask {
                    await FeedUpdateTask.execute(
                        feedObjectID: feedUpdate.objectID,
                        url: feedUpdate.url,
                        updateMeta: feedUpdate.updateMeta
                    )
                    self.progress.completedUnitCount += 1
                }
                working += 1
            }

            await taskGroup.waitForAll()
        }
        
        progress.completedUnitCount += 1

        await CleanupTask.execute()
        await AnalyzeTask.execute()

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
            await FeedUpdateTask.execute(
                feedObjectID: feed.objectID,
                url: url,
                updateMeta: true
            )
        }
        
        feed.objectWillChange.send()
        feed.page?.objectWillChange.send()
    }
    
    private func updateInfoForAllFeeds() -> [FeedUpdateInfo] {
        var feedUpdates: [FeedUpdateInfo] = []
        
        let context = DataController.shared.container.newBackgroundContext()
        
        context.performAndWait {
            let request = Page.fetchRequest()
            request.sortDescriptors = [NSSortDescriptor(keyPath: \Page.userOrder, ascending: true)]
            guard let pages = try? context.fetch(request) as [Page] else { return }
            
            for feed in pages.flatMap({ $0.feedsArray }) {
                guard let url = feed.url else { continue }
                
                feedUpdates.append(FeedUpdateInfo(
                    objectID: feed.objectID,
                    url: url,
                    updateMeta: feed.needsMetaUpdate
                ))
            }
        }
        
        return feedUpdates
    }
}
