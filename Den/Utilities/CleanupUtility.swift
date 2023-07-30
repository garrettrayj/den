//
//  CleanupUtility.swift
//  Den
//
//  Created by Garrett Johnson on 7/22/23.
//  Copyright © 2023 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import CoreData
import OSLog

struct CleanupUtility {
    static func purgeOrphans(context: NSManagedObjectContext) throws {
        var orphanedFeedDatas = 0
        let feedDatas = try context.fetch(FeedData.fetchRequest()) as [FeedData]
        for feedData in feedDatas where feedData.feed == nil {
            orphanedFeedDatas += 1
            context.delete(feedData)
        }

        var orphanedTrends = 0
        let trends = try context.fetch(Trend.fetchRequest()) as [Trend]
        for trend in trends where trend.profile == nil {
            orphanedTrends += 1
            context.delete(trend)
        }

        try context.save()

        Logger.main.info("""
        Cleanup complete. Purged \(orphanedFeedDatas) FeedData records \
        and \(orphanedTrends) Trends.
        """)
    }
}
