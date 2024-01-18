//
//  RefreshManager.swift
//  Den
//
//  Created by Garrett Johnson on 4/1/23.
//  Copyright © 2023 Garrett Johnson
//

import CoreData
import OSLog

final class RefreshManager {
    static public func refresh(
        profile: Profile,
        session: URLSession = URLSession.shared
    ) async {
        await MainActor.run {
            NotificationCenter.default.post(name: .refreshStarted, object: profile.objectID)
        }

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
        let analyzeTask = AnalyzeTask(profileObjectID: profile.objectID)
        let maxConcurrency = min(4, ProcessInfo().activeProcessorCount)

        _ = await withTaskGroup(of: Void.self, returning: Void.self, body: { taskGroup in
                var working: Int = 0
                for task in feedUpdateTasks {
                    if working >= maxConcurrency {
                        await taskGroup.next()
                        working = 0
                    }
                    taskGroup.addTask { _ = await task.execute() }
                    working += 1
                }

                await taskGroup.waitForAll()
            }
        )
        
        await MainActor.run {
            NotificationCenter.default.post(name: .refreshProgressed, object: profile.objectID)
        }
    
        await analyzeTask.execute()

        RefreshedDateStorage.setRefreshed(profile, date: .now)

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
