//
//  RSSFeedUpdater.swift
//  Den
//
//  Created by Garrett Johnson on 10/30/22.
//  Copyright © 2022 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftData
import OSLog

import FeedKit

struct RSSFeedUpdater {
    static func updateFeed(
        feed: Feed,
        feedData: FeedData,
        rssFeed: RSSFeed,
        context: ModelContext
    ) {
        if feed.title == nil, let feedTitle = rssFeed.title {
            feed.title = feedTitle.preparingTitle()
        }
        feedData.link = rssFeed.webpage
        feedData.format = "RSS"
        
        guard let rssFeedItems = rssFeed.itemsSortedByDateAndTitle else { return }

        var existingItemLinks = feedData.itemsArray.compactMap({ $0.link })
        for rssFeedItem in rssFeedItems.prefix(Feed.totalItemLimit) {
            // Continue if link is missing
            guard let itemLink = rssFeedItem.linkURL else {
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
            
            RSSItemLoader.populateItem(item: item, itemLink: itemLink, rssFeedItem: rssFeedItem)
            
            item.anaylyzeTitleTags()
        }
    }
    
    static func updateMeta(
        feedData: FeedData,
        rssFeed: RSSFeed,
        webpageMetadata: WebpageMetadata?
    ) {
        // RSS images are generally no good, so prefer webpage meta for icon image
        if let topIconURL = webpageMetadata?.icons.first?.url {
            feedData.image = topIconURL
        } else if
            let urlString = rssFeed.image?.url,
            let url = URL(string: urlString, relativeTo: feedData.link)
        {
            feedData.image = url.absoluteURL
        }

        if let topFavicon = webpageMetadata?.favicons.first?.url {
            feedData.favicon = topFavicon
        }

        if let topBanner = webpageMetadata?.banners.first?.url {
            feedData.banner = topBanner
        } else if let topWebpageIcon = webpageMetadata?.icons.first?.url {
            feedData.banner = topWebpageIcon
        }

        if feedData.image == nil && feedData.banner != nil {
            feedData.image = feedData.banner
        }

        if let description = rssFeed.description, description != "" {
            feedData.metaDescription = description.trimmingCharacters(in: .whitespacesAndNewlines)
        } else if let description = webpageMetadata?.description {
            feedData.metaDescription = description.trimmingCharacters(in: .whitespacesAndNewlines)
        }

        if let copyright = rssFeed.copyright, copyright != "" {
            feedData.copyright = copyright.trimmingCharacters(in: .whitespacesAndNewlines)
        } else if let copyright = webpageMetadata?.copyright {
            feedData.copyright = copyright.trimmingCharacters(in: .whitespacesAndNewlines)
        }
    }
}
