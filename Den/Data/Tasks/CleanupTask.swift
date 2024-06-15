//
//  CleanupTask.swift
//  Den
//
//  Created by Garrett Johnson on 6/15/24.
//  Copyright © 2024 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import Foundation
import OSLog
import SwiftData

struct CleanupTask {
    func execute() async {
        let context = ModelContext(DataController.shared.container)
        
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
