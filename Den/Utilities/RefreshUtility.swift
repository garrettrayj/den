//
//  RefreshManager.swift
//  Den
//
//  Created by Garrett Johnson on 10/30/22.
//  Copyright © 2022 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import CoreData
import SwiftUI

import FeedKit

struct RefreshUtility {
    static func refresh(profile: Profile) async {
        let maxConcurrency = min(4, ProcessInfo().activeProcessorCount)
        let container = PersistenceController.shared.container

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
                    feed.feedData!.metaFetched! < Date(timeIntervalSinceNow: -7 * 24 * 60 * 60) {
                    fetchMeta = true
                }

                feedOps.append(
                    FeedRefreshOperation(
                        container: container,
                        feedObjectID: feed.objectID,
                        pageObjectID: feed.page?.objectID,
                        url: url,
                        updateMetadata: fetchMeta
                    )
                )
            }
        }

        _ = await withTaskGroup(of: Void.self, returning: Void.self, body: { taskGroup in
                var working: Int = 0
                for operation in feedOps {
                    if working >= maxConcurrency {
                        await taskGroup.next()
                        working = 0
                    }

                    taskGroup.addTask {
                        _ = await operation.execute()
                    }
                    working += 1
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
            RefreshedDateStorage.shared.setRefreshed(profile, date: .now)
            NotificationCenter.default.post(name: .refreshFinished, object: profile.objectID)
        }
    }

    static func refresh(feed: Feed) async {
        let container = PersistenceController.shared.container

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
                updateMetadata: fetchMeta
            )
            _ = await feedOp.execute()
        }
    }
}
