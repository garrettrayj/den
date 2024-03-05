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
    static public func refresh(profile: Profile) async {
        await MainActor.run {
            NotificationCenter.default.post(name: .refreshStarted, object: profile.objectID)
        }

        await withTaskGroup(of: Void.self, returning: Void.self, body: { taskGroup in
            let maxConcurrency = min(4, ProcessInfo().activeProcessorCount)
            let feedUpdateTasks: [FeedUpdateTask] = profile.feedsArray.compactMap { feed in
                guard let url = feed.url else { return nil }
                return FeedUpdateTask(
                    feedObjectID: feed.objectID,
                    pageObjectID: feed.page?.objectID,
                    profileObjectID: feed.page?.profile?.objectID,
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
            NotificationCenter.default.post(name: .refreshProgressed, object: profile.objectID)
        }
    
        await AnalyzeTask(profileObjectID: profile.objectID).execute()

        RefreshedDateStorage.setRefreshed(profile.id?.uuidString, date: .now)

        await MainActor.run {
            NotificationCenter.default.post(name: .refreshFinished, object: profile.objectID)
        }
    }

    static func refresh(feed: Feed) async {
        if let url = feed.url {
            let feedUpdateTask = FeedUpdateTask(
                feedObjectID: feed.objectID,
                pageObjectID: feed.page?.objectID,
                profileObjectID: feed.page?.profile?.objectID,
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
