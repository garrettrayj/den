//
//  CleanupTask.swift
//  Den
//
//  Created by Garrett Johnson on 6/14/24.
//  Copyright © 2024 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import CoreData
import OSLog

struct CleanupTask {
    static func execute(container: NSPersistentContainer) async {
        let context = container.newBackgroundContext()
        
        context.performAndWait {
            guard let feedDatas = try? context.fetch(FeedData.fetchRequest()) as [FeedData] else {
                Logger.main.error("Unable to fetch FeedData records for cleanup")
                return
            }
            
            var orphansPurged = 0
            for feedData in feedDatas where feedData.feed == nil {
                context.delete(feedData)
                orphansPurged += 1
            }
            
            do {
                try context.save()
                Logger.main.info("Purged \(orphansPurged) orphaned feed data records.")
            } catch {
                CrashUtility.handleCriticalError(error as NSError)
            }
        }
    }
}
