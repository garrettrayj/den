//
//  AtomFeedMetaUpdate.swift
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

struct AtomFeedMetaUpdate {
    let feed: Feed
    let feedData: FeedData
    let source: AtomFeed
    let context: NSManagedObjectContext
    let webpageMetadata: WebpageMetadata?

    func execute() {
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
