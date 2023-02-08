//
//  AtomFeedUpdate.swift
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

struct AtomFeedUpdate {
    let feed: Feed
    let feedData: FeedData
    let source: AtomFeed
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

        if let sourceItems = source.entries {
            let existingItemLinks = feedData.itemsArray.compactMap({ $0.link })
            for sourceItem in sourceItems.prefix(feed.wrappedItemLimit + UIConstants.extraItemLimit) {
                // Continue if link is missing
                guard let itemLink = sourceItem.linkURL else {
                    Logger.ingest.notice("Missing link for item.")
                    continue
                }

                // Continue if item already exists
                if existingItemLinks.contains(itemLink) {
                    continue
                }

                let item = Item.create(moc: context, feedData: feedData)
                let load = AtomItemLoad(item: item, source: sourceItem)
                load.apply()

                item.anaylyzeTitleTags()
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
        if
            let urlString = source.icon,
            let url = URL(string: urlString, relativeTo: feedData.link)
        {
            feedData.image = url.absoluteURL
        } else if
            let urlString = source.logo,
            let url = URL(string: urlString, relativeTo: feedData.link)
        {
            feedData.image = url.absoluteURL
        } else if let topIconURL = webpageMetadata?.icons.topRanked?.url {
            feedData.image = topIconURL
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

        if let subtitle = source.subtitle, subtitle.value != "" {
            feedData.metaDescription = subtitle.value
        } else if let description = webpageMetadata?.description {
            feedData.metaDescription = description
        }

        if let copyright = source.rights, copyright != "" {
            feedData.copyright = copyright
        } else if let copyright = webpageMetadata?.copyright {
            feedData.copyright = copyright
        }
    }
}
