//
//  RSSFeedUpdate.swift
//  Den
//
//  Created by Garrett Johnson on 10/30/22.
//  Copyright © 2022 Garrett Johnson
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
        feedData.format = "RSS"

        if let sourceItems = source.items {
            var existingItemLinks = feedData.itemsArray.compactMap({ $0.link })
            for rawItem in sourceItems.prefix(Feed.totalItemLimit) {
                // Continue if link is missing
                guard let itemLink = rawItem.linkURL else {
                    Logger.main.notice("Missing link for item.")
                    continue
                }

                // Continue if item already exists
                if existingItemLinks.contains(itemLink) {
                    continue
                } else {
                    existingItemLinks.append(itemLink)
                }

                let item = Item.create(moc: context, feedData: feedData)
                let load = RSSItemLoad(item: item, source: rawItem)
                load.apply()
                item.anaylyzeTitleTags()
                feedData.addToItems(item)
            }

            // Remove items no longer in feed
            let sourceItemURLs = sourceItems.compactMap { $0.linkURL }
            for item in feedData.itemsArray {
                if let link = item.link, sourceItemURLs.contains(link) == false {
                    context.delete(item)
                }
            }
        }
    }
}
