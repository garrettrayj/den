//
//  AyncRefreshManager.swift
//  Den
//
//  Created by Garrett Johnson on 10/30/22.
//  Copyright © 2022 Garrett Johnson. All rights reserved.
//

import CoreData
import Foundation

import FeedKit


struct AsyncRefreshManager {
    static func refresh(container: NSPersistentContainer, profile: Profile) async {
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: .refreshStarted, object: profile.objectID)
        }
        
        var feedOps: [FeedRefreshOperation] = []
        for feed in profile.feedsArray {
            if let url = feed.url {
                var fetchMeta = false
                // Fetch meta (favicon, etc.) on first refresh or if user cleared cache, then check for updates occasionally
                if feed.feedData?.metaFetched == nil || feed.feedData!.metaFetched! < Date(timeIntervalSinceNow: -30 * 24 * 60 * 60) {
                    fetchMeta = true
                }
                
                feedOps.append(
                    FeedRefreshOperation(
                        container: container,
                        feedObjectID: feed.objectID,
                        pageObjectID: feed.page?.objectID,
                        url: url,
                        fetchMeta: fetchMeta
                    )
                )
            }
        }
        
        let _ = await withTaskGroup(
            of: RefreshStatus.self,
            returning: [RefreshStatus].self,
            body: { taskGroup in
                for op in feedOps {
                    taskGroup.addTask {
                        let refreshStatus = await op.execute()
                        return refreshStatus
                    }
                }
                
                var childTaskResults: [RefreshStatus] = []
                for await result in taskGroup {
                    // Set operation name as key and operation result as value
                    childTaskResults.append(result)
                }
                
                DispatchQueue.main.async {
                    NotificationCenter.default.post(name: .pagesRefreshed, object: profile.objectID)
                }
                
                // All child tasks finish running, thus task group result
                return childTaskResults
            }
        )
        
        // Do analysis here
        let analysisOperation = AnalysisOperation(container: container, profileObjectID: profile.objectID)
        await analysisOperation.execute()
        
        // Cleanup
        let cleanOperation = CleanOperation(container: container, profileObjectID: profile.objectID)
        await cleanOperation.execute()
        
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: .refreshFinished, object: profile.objectID)
        }
    }
    
    static func refresh(container: NSPersistentContainer, feed: Feed) async {
        if let url = feed.url {
            var fetchMeta = false
            // Fetch meta (favicon, etc.) on first refresh or if user cleared cache, then check for updates occasionally
            if feed.feedData?.metaFetched == nil || feed.feedData!.metaFetched! < Date(timeIntervalSinceNow: -30 * 24 * 60 * 60) {
                fetchMeta = true
            }
            
            let feedOp = FeedRefreshOperation(
                container: container,
                feedObjectID: feed.objectID,
                pageObjectID: feed.page?.objectID,
                url: url,
                fetchMeta: fetchMeta
            )
            let _ = await feedOp.execute()
        }
    }
}
