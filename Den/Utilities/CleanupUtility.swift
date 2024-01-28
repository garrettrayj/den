//
//  CleanupUtility.swift
//  Den
//
//  Created by Garrett Johnson on 7/22/23.
//  Copyright © 2023 Garrett Johnson
//
//  SPDX-License-Identifier: NONE
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
        Logger.main.info("Purged \(orphanedFeedDatas) orphaned feed data records.")

        var orphanedTrends = 0
        let trends = try context.fetch(Trend.fetchRequest()) as [Trend]
        for trend in trends where trend.profile == nil {
            orphanedTrends += 1
            context.delete(trend)
        }
        Logger.main.info("Purged \(orphanedTrends) orphaned trends.")
    }

    static func removeExpiredHistory(context: NSManagedObjectContext, profile: Profile) throws {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "History")
        fetchRequest.fetchOffset = 100000
        fetchRequest.predicate = NSPredicate(format: "%K = %@", #keyPath(History.profile), profile)

        // Create a batch delete request for the fetch request
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)

        // Specify the result of the NSBatchDeleteRequest
        // should be the NSManagedObject IDs for the deleted objects
        deleteRequest.resultType = .resultTypeObjectIDs

        // Perform the batch delete
        let batchDelete = try? context.execute(deleteRequest) as? NSBatchDeleteResult

        guard let deleteResult = batchDelete?.result as? [NSManagedObjectID] else { return }

        let deletedObjects: [AnyHashable: Any] = [NSDeletedObjectsKey: deleteResult]

        // Merge the delete changes into the managed object context
        NSManagedObjectContext.mergeChanges(
            fromRemoteContextSave: deletedObjects,
            into: [context]
        )

        Logger.main.info("""
        Expired history removed for profile: \
        \(profile.id?.uuidString ?? "NA", privacy: .public)
        """)
    }

    static func trimSearches(context: NSManagedObjectContext, profile: Profile) {
        guard profile.searchesArray.count > 20 else { return }
        var removedSearches = 0
        profile.searchesArray.suffix(from: 20).forEach { search in
            context.delete(search)
            removedSearches += 1
        }
        Logger.main.info("""
        Trimmed \(removedSearches) searches for profile: \
        \(profile.id?.uuidString ?? "NA", privacy: .public)
        """)
    }
}
