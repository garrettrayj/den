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
    let webpageMetadata: WebpageMetadata?
    let updateMetadata: Bool
    let context: NSManagedObjectContext

    func execute() {
        if feed.title == nil, let feedTitle = source.title {
            feed.title = feedTitle.preparingTitle()
        }

        feedData.link = source.webpage

        if updateMetadata {
            populateMetadata(feedData: feedData)
        }

        if let sourceItems = source.items {
            let existingItemLinks = feedData.itemsArray.compactMap({ $0.link })
            for rawItem in sourceItems.prefix(feed.wrappedItemLimit) {
                // Continue if link is missing
                guard let itemLink = rawItem.linkURL else {
                    Logger.ingest.notice("Missing link for item.")
                    continue
                }

                // Continue if item already exists
                if existingItemLinks.contains(itemLink) {
                    continue
                }

                let item = Item.create(moc: context, feedData: feedData)
                let load = RSSItemLoad(item: item, source: rawItem)
                load.apply()
                item.anaylyzeTitleTags()
                feedData.addToItems(item)
            }

            let sourceItemURLs = sourceItems.compactMap { $0.linkURL }
            for item in feedData.itemsArray {
                if let link = item.link, sourceItemURLs.contains(link) == false {
                    context.delete(item)
                }
            }
        }
    }

    private func populateMetadata(feedData: FeedData) {
        // RSS images are not good in general, so prefer webpage meta for icon image
        if let topIconURL = webpageMetadata?.icons.topRanked?.url {
            feedData.image = topIconURL
        } else if
            let urlString = source.image?.url,
            let url = URL(string: urlString, relativeTo: feedData.link)
        {
            feedData.image = url.absoluteURL
        }

        if let topFavicon = webpageMetadata?.favicons.topRanked?.url {
            feedData.favicon = topFavicon
        }

        if let topBanner = webpageMetadata?.banners.topRanked?.url {
            feedData.banner = topBanner
        }

        if feedData.image == nil && feedData.banner != nil {
            feedData.image = feedData.banner
        }

        if let description = source.description, description != "" {
            feedData.metaDescription = description
        } else if let description = webpageMetadata?.description {
            feedData.metaDescription = description
        }

        if let copyright = source.copyright, copyright != "" {
            feedData.copyright = copyright
        } else if let copyright = webpageMetadata?.copyright {
            feedData.copyright = copyright
        }
    }
}
