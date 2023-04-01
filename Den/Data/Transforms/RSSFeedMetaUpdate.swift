//
//  RSSFeedMetaUpdate.swift
//  Den
//
//  Created by Garrett Johnson on 4/1/23.
//  Copyright © 2023 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import CoreData
import OSLog

import FeedKit

struct RSSFeedMetaUpdate {
    let feed: Feed
    let feedData: FeedData
    let source: RSSFeed
    let context: NSManagedObjectContext
    let webpageMetadata: WebpageMetadata?

    func execute() {
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
