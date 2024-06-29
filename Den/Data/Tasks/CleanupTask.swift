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
        let modelContext = ModelContext(DataController.shared.container)

        guard let feedDatas = try? modelContext.fetch(FetchDescriptor<FeedData>()) as [FeedData] else {
            Logger.main.error("Unable to fetch FeedData records for cleanup")
            return
        }
        
        var orphansPurged = 0
        for feedData in feedDatas where feedData.feed == nil {
            modelContext.delete(feedData)
            orphansPurged += 1
        }
        
        try? modelContext.save()
        
        Logger.main.info("Purged \(orphansPurged) orphaned feed data records.")
    }
}
