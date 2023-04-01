//
//  DataCleanupOperation.swift
//  Den
//
//  Created by Garrett Johnson on 4/1/23.
//  Copyright © 2023 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import CoreData
import OSLog

final class DataCleanupOperation: Operation {
    override func main() {
        PersistenceController.shared.container.performBackgroundTask { context in
            try? self.cleanupData(context: context)
        }
    }

    /**
     Remove abandoned FeedData entities. Related Item entities will also be removed via cascade.
     */
    private func cleanupData(context: NSManagedObjectContext) throws {
        var orphansPurged = 0
        let feedDatas = try context.fetch(FeedData.fetchRequest()) as [FeedData]
        for feedData in feedDatas where feedData.feed == nil {
            context.delete(feedData)
            orphansPurged += 1
        }
        try context.save()
        Logger.main.info("Data cleanup finished. Purged \(orphansPurged) orphaned FeedData entities")
    }
}
