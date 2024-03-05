//
//  JSONFeedUpdate.swift
//  Den
//
//  Created by Garrett Johnson on 10/31/22.
//  Copyright © 2022 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import CoreData
import OSLog

import FeedKit

struct JSONFeedUpdate {
    let feed: Feed
    let feedData: FeedData
    let source: JSONFeed
    let context: NSManagedObjectContext

    let imageSelection = ImageSelection()

    func execute() {
        if feed.title == nil, let feedTitle = source.title {
            feed.title = feedTitle.preparingTitle()
        }
        feedData.link = source.webpage
        feedData.format = "JSON"

        let sortedSourceItems = source.items?.sorted(using: [
            SortDescriptor(\.datePublished, order: .reverse),
            SortDescriptor(\.title)
        ])
        
        if let sourceItems = sortedSourceItems {
            var existingItemLinks = feedData.itemsArray.compactMap({ $0.link })
            for sourceItem in sourceItems.prefix(Feed.totalItemLimit) {
                // Continue if link is missing
                guard let itemLink = sourceItem.linkURL else {
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
                let load = JSONItemLoad(item: item, source: sourceItem)
                load.apply()

                item.anaylyzeTitleTags()
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
