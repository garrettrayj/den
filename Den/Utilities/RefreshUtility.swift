//
//  AyncRefreshManager.swift
//  Den
//
//  Created by Garrett Johnson on 10/30/22.
//  Copyright © 2022 Garrett Johnson. All rights reserved.
//

import CoreData
import SwiftUI

import FeedKit

struct RefreshUtility {
    static func refresh(container: NSPersistentContainer?, profile: Profile) async {
        guard let container = container else { return }

        DispatchQueue.main.async {
            NotificationCenter.default.post(name: .refreshStarted, object: profile.objectID)
        }

        var feedOps: [FeedRefreshOperation] = []
        for feed in profile.feedsArray {
            if let url = feed.url {
                var fetchMeta = false
                // Fetch meta (favicon, etc.) on first refresh or if user cleared cache,
                // then check for updates occasionally
                if feed.feedData?.metaFetched == nil ||
                    feed.feedData!.metaFetched! < Date(timeIntervalSinceNow: -30 * 24 * 60 * 60) {
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

        _ = await withTaskGroup(
            of: Void.self,
            returning: Void.self,
            body: { taskGroup in
                for (idx, operation) in feedOps.enumerated() {
                    if idx % 6 == 5 { // max of six at a time
                        await taskGroup.next()
                    }

                    taskGroup.addTask {
                        _ = await operation.execute()
                    }
                }

                await taskGroup.waitForAll()

                DispatchQueue.main.async {
                    NotificationCenter.default.post(name: .pagesRefreshed, object: profile.objectID)
                }
            }
        )

        let cleanOperation = CleanOperation(container: container, profileObjectID: profile.objectID)
        await cleanOperation.execute()

        let analysisOperation = AnalysisOperation(container: container, profileObjectID: profile.objectID)
        await analysisOperation.execute()

        DispatchQueue.main.async {
            NotificationCenter.default.post(name: .refreshFinished, object: profile.objectID)
        }

    }

    static func refresh(container: NSPersistentContainer?, feed: Feed) async {
        guard let container = container else { return }
        if let url = feed.url {
            var fetchMeta = false
            // Fetch meta (favicon, etc.) on first refresh or if user cleared cache, then check for updates occasionally
            if feed.feedData?.metaFetched == nil ||
                feed.feedData!.metaFetched! < Date(timeIntervalSinceNow: -30 * 24 * 60 * 60) {
                fetchMeta = true
            }

            let feedOp = FeedRefreshOperation(
                container: container,
                feedObjectID: feed.objectID,
                pageObjectID: feed.page?.objectID,
                url: url,
                fetchMeta: fetchMeta
            )
            _ = await feedOp.execute()
        }
    }
}
