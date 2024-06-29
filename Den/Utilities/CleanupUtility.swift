//
//  CleanupUtility.swift
//  Den
//
//  Created by Garrett Johnson on 7/22/23.
//  Copyright © 2023 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftData
import OSLog

struct CleanupUtility {
    static func upgradeBookmarks(modelContext: ModelContext) {
        var request = FetchDescriptor<Bookmark>()
        request.predicate = #Predicate<Bookmark> { $0.created == nil }
        
        guard
            let bookmarks = try? modelContext.fetch(request) as [Bookmark],
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
        
        try? modelContext.save()
    }
}
