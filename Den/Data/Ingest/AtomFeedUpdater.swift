//
//  AtomFeedUpdater.swift
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

struct AtomFeedUpdater {
    static func updateFeed(
        feed: Feed,
        feedData: FeedData,
        atomFeed: AtomFeed,
        context: NSManagedObjectContext
    ) {
        if feed.title == nil, let feedTitle = atomFeed.title {
            feed.title = feedTitle.preparingTitle()
        }
        
        feedData.link = atomFeed.webpage
        feedData.format = "Atom"
        
        guard let atomFeedEntries = atomFeed.entriesSortedByDateAndTitle else { return }

        var existingItemLinks = feedData.itemsArray.compactMap({ $0.link })
        for atomFeedEntry in atomFeedEntries.prefix(Feed.totalItemLimit) {
            // Continue if link is missing
            guard let itemLink = atomFeedEntry.linkURL else {
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
            
            AtomItemLoader.populateItem(item: item, itemLink: itemLink, atomFeedEntry: atomFeedEntry)

            item.anaylyzeTitleTags()
        }

        // Remove items no longer in feed
        let sourceItemURLs = atomFeedEntries.compactMap { $0.linkURL }
        for item in feedData.itemsArray {
            if let link = item.link, !sourceItemURLs.contains(link) {
                context.delete(item)
            }
        }
    }
    
    // swiftlint:disable cyclomatic_complexity
    static func updateMeta(
        feedData: FeedData,
        atomFeed: AtomFeed,
        webpageMetadata: WebpageMetadata?
    ) {
        if
            let urlString = atomFeed.icon,
            let url = URL(string: urlString, relativeTo: feedData.link)
        {
            feedData.image = url.absoluteURL
        } else if
            let urlString = atomFeed.logo,
            let url = URL(string: urlString, relativeTo: feedData.link)
        {
            feedData.image = url.absoluteURL
        } else if let topIconURL = webpageMetadata?.icons.first?.url {
            feedData.image = topIconURL
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

        if let subtitle = atomFeed.subtitle?.value, subtitle != "" {
            feedData.metaDescription = subtitle.trimmingCharacters(in: .whitespacesAndNewlines)
        } else if let description = webpageMetadata?.description {
            feedData.metaDescription = description.trimmingCharacters(in: .whitespacesAndNewlines)
        }

        if let copyright = atomFeed.rights, copyright != "" {
            feedData.copyright = copyright.trimmingCharacters(in: .whitespacesAndNewlines)
        } else if let copyright = webpageMetadata?.copyright {
            feedData.copyright = copyright.trimmingCharacters(in: .whitespacesAndNewlines)
        }
    }
    // swiftlint:enable cyclomatic_complexity
}
