//
//  RefreshManager.swift
//  Den
//
//  Created by Garrett Johnson on 4/1/23.
//  Copyright © 2023 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import Combine
import CoreData
import OSLog
import WidgetKit

@MainActor
final class RefreshManager: ObservableObject {
    @Published var refreshing = false
    @Published var autoRefreshActive = false
    
    let progress = Progress()
    
    #if os(macOS)
    private var timer: Timer?
    
    func startAutoRefresh(container: NSPersistentContainer, interval: TimeInterval) {
        Logger.main.debug("Starting auto refresh with \(Int(interval)) second interval")
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { _ in
            Task {
                await self.refresh(container: container)
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
    
    func refresh(container: NSPersistentContainer, inBackground: Bool = false) async {
        guard progress.totalUnitCount == 0 else { return }

        if !inBackground {
            await MainActor.run { refreshing = true }
        }
        
        var feedUpdates: [(NSManagedObjectID, URL, Bool)] = []
        
        let context = container.newBackgroundContext()
        
        context.performAndWait {
            let request = Page.fetchRequest()
            request.sortDescriptors = [NSSortDescriptor(keyPath: \Page.userOrder, ascending: true)]
            guard let pages = try? context.fetch(request) as [Page] else { return }
            
            feedUpdates = pages.flatMap { $0.feedsArray }.compactMap { feed in
                guard let url = feed.url else { return nil }
                return (feed.objectID, url, feed.needsMetaUpdate)
            }
        }
        
        progress.totalUnitCount = Int64(feedUpdates.count)

        let maxConcurrency = min(3, ProcessInfo().activeProcessorCount)
        
        await withTaskGroup(of: Void.self, returning: Void.self) { taskGroup in
            var working = 0
            for (feedObjectID, url, needsMetaUpdate) in feedUpdates {
                if working >= maxConcurrency {
                    await taskGroup.next()
                    working = 0
                }
                
                taskGroup.addTask {
                    await FeedUpdateTask.execute(
                        container: container,
                        feedObjectID: feedObjectID,
                        url: url,
                        updateMeta: needsMetaUpdate
                    )
                    self.progress.completedUnitCount += 1
                }
                working += 1
            }

            await taskGroup.waitForAll()
        }
        
        progress.completedUnitCount += 1

        await CleanupTask.execute(container: container)
        await AnalyzeTask.execute(container: container)

        UserDefaults.standard.set(Date().timeIntervalSince1970, forKey: "Refreshed")
        WidgetCenter.shared.reloadAllTimelines()
        
        if !inBackground {
            await MainActor.run { refreshing = false }
        }
        
        progress.completedUnitCount = 0
        progress.totalUnitCount = 0
    }

    func refresh(container: NSPersistentContainer, feed: Feed) async {
        if let url = feed.url {
            await FeedUpdateTask.execute(
                container: container,
                feedObjectID: feed.objectID,
                url: url,
                updateMeta: true
            )
        }
        
        feed.objectWillChange.send()
        feed.page?.objectWillChange.send()
    }
}
