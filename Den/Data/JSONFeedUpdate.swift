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
    let webpageMetadata: WebpageMetadata?
    let updateMetadata: Bool
    let context: NSManagedObjectContext

    let imageSelection = ImageSelection()

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
            for sourceItem in sourceItems.prefix(feed.wrappedItemLimit + UIConstants.extraItemLimit) {
                // Continue if link is missing
                guard let itemLink = sourceItem.linkURL else {
                    Logger.ingest.notice("Missing link for item.")
                    continue
                }

                // Continue if item already exists
                if (existingItemLinks.contains(where: { $0 == itemLink})) {
                    continue
                }

                let item = Item.create(moc: context, feedData: feedData)
                let load = JSONItemLoad(item: item, source: sourceItem)
                load.apply()

                item.anaylyzeTitleTags()
            }
        }
    }

    private func populateMetadata(feedData: FeedData) {
        if
            let urlString = source.icon,
            let url = URL(string: urlString, relativeTo: feedData.link)
        {
            feedData.image = url.absoluteURL
        } else if let topIconURL = webpageMetadata?.icons.topRanked?.url {
            feedData.image = topIconURL
        }

        if
            let urlString = source.favicon,
            let url = URL(string: urlString, relativeTo: feedData.link)
        {
            feedData.favicon = url.absoluteURL
        } else if let topFavicon = webpageMetadata?.favicons.topRanked?.url {
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

        if let copyright = webpageMetadata?.copyright {
            feedData.copyright = copyright
        }
    }
}
