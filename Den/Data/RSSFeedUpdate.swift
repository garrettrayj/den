//
//  RSSFeedUpdate.swift
//  Den
//
//  Created by Garrett Johnson on 10/30/22.
//  Copyright © 2022 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import CoreData
import OSLog

import FeedKit

struct RSSFeedUpdate {
    let feed: Feed
    let feedData: FeedData
    let source: RSSFeed
    let context: NSManagedObjectContext

    func execute() {
        if feed.title == nil, let feedTitle = source.title {
            feed.title = feedTitle.preparingTitle()
        }

        feedData.link = source.webpage

        if
            let urlString = source.image?.url,
            let url = URL(string: urlString, relativeTo: feedData.link)
        {
            feedData.image = url.absoluteURL
        }

        if let rawItems = source.items {
            let existingItemLinks = feedData.itemsArray.compactMap({ $0.link })
            for rawItem in rawItems.prefix(feed.wrappedItemLimit) {
                // Continue if link is missing
                guard let itemLink = rawItem.linkURL else {
                    Logger.ingest.notice("Missing link for item.")
                    continue
                }

                // Continue if item already exists
                if (existingItemLinks.contains(where: { $0 == itemLink})) {
                    continue
                }

                let item = Item.create(moc: context, feedData: feedData)
                let load = RSSItemLoad(item: item, source: rawItem)
                load.apply()

                item.anaylyzeTitleTags()
            }
        }
    }
}
