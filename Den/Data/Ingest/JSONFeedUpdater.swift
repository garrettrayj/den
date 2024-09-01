//
//  JSONFeedUpdater.swift
//  Den
//
//  Created by Garrett Johnson on 10/31/22.
//  Copyright © 2022 Garrett Johnson. All rights reserved.
//

import CoreData
import OSLog

import FeedKit

struct JSONFeedUpdater {
    static func updateFeed(
        feed: Feed,
        feedData: FeedData,
        jsonFeed: JSONFeed,
        context: NSManagedObjectContext
    ) {
        if feed.title == nil, let feedTitle = jsonFeed.title {
            feed.title = feedTitle.preparingTitle()
        }
        feedData.link = jsonFeed.webpage
        feedData.format = "JSON"

        guard let jsonFeedItems = jsonFeed.itemsSortedByDateAndTitle else { return }
        
        var existingItemLinks = feedData.itemsArray.compactMap({ $0.link })
        
        for jsonFeedItem in jsonFeedItems.prefix(Feed.totalItemLimit) {
            // Continue if link is missing
            guard let itemLink = jsonFeedItem.linkURL else {
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
            
            JSONItemLoader.populateItem(item: item, itemLink: itemLink, jsonFeedItem: jsonFeedItem)
            
            item.anaylyzeTitleTags()
        }
    }
    
    static func updateMeta(
        feedData: FeedData,
        jsonFeed: JSONFeed,
        webpageMetadata: WebpageMetadata?
    ) {
        if
            let urlString = jsonFeed.icon,
            let url = URL(string: urlString, relativeTo: feedData.link)
        {
            feedData.image = url.absoluteURL
        } else if let topIconURL = webpageMetadata?.icons.first?.url {
            feedData.image = topIconURL
        }

        if
            let urlString = jsonFeed.favicon,
            let url = URL(string: urlString, relativeTo: feedData.link)
        {
            feedData.favicon = url.absoluteURL
        } else if let topFavicon = webpageMetadata?.favicons.first?.url {
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

        if let description = jsonFeed.description, description != "" {
            feedData.metaDescription = description.trimmingCharacters(in: .whitespacesAndNewlines)
        } else if let description = webpageMetadata?.description {
            feedData.metaDescription = description.trimmingCharacters(in: .whitespacesAndNewlines)
        }

        if let copyright = webpageMetadata?.copyright {
            feedData.copyright = copyright.trimmingCharacters(in: .whitespacesAndNewlines)
        }
    }
}
