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
        Logger.main.info("Purged \(orphanedFeedDatas) orphaned feed data records.")
    }

    static func removeExpiredHistory(context: NSManagedObjectContext) throws {
        PersistenceController.truncate(History.self, context: context, offset: 100000)

        Logger.main.info("Expired history removed.")
    }

    static func trimSearches(context: NSManagedObjectContext) {
        guard let searches = try? context.fetch(Search.fetchRequest()) as [Search] else {
            return
        }
        
        guard searches.count > 20 else { return }
        var removedSearches = 0
        searches.suffix(from: 20).forEach { search in
            context.delete(search)
            removedSearches += 1
        }
        Logger.main.info("Trimmed \(removedSearches) searches.")
    }
    
    static func upgradeBookmarks(context: NSManagedObjectContext) {
        let request = Bookmark.fetchRequest()
        request.predicate = NSPredicate(format: "created = nil")
        
        guard
            let bookmarks = try? context.fetch(request) as [Bookmark],
            !bookmarks.isEmpty
        else {
            return
        }
        
        for bookmark in bookmarks {
            bookmark.created = bookmark.published ?? bookmark.ingested ?? Date(timeIntervalSince1970: 0)
            
            bookmark.site = bookmark.feed?.title
            bookmark.favicon = bookmark.feed?.feedData?.favicon
            bookmark.hideImage = bookmark.feed?.hideImages ?? false
            bookmark.hideByline = bookmark.feed?.hideBylines ?? false
            bookmark.hideTeaser = bookmark.feed?.hideTeasers ?? false
            bookmark.largePreview = bookmark.feed?.largePreviews ?? false
        }
        
        try? context.save()
    }
}
