//
//  JSONFeedMetaUpdate.swift
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

struct JSONFeedMetaUpdate {
    let feed: Feed
    let feedData: FeedData
    let source: JSONFeed
    let context: NSManagedObjectContext
    let webpageMetadata: WebpageMetadata?

    func execute() {
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
        } else if let topWebpageIcon = webpageMetadata?.icons.topRanked?.url {
            feedData.banner = topWebpageIcon
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
