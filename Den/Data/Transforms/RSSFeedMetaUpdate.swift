//
//  RSSFeedMetaUpdate.swift
//  Den
//
//  Created by Garrett Johnson on 4/1/23.
//  Copyright © 2023 Garrett Johnson
//
//  SPDX-License-Identifier: NONE
//

import CoreData
import OSLog

import FeedKit

struct RSSFeedMetaUpdate {
    let feedData: FeedData
    let source: RSSFeed
    let webpageMetadata: WebpageMetadata.Results?

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
        } else if let topWebpageIcon = webpageMetadata?.icons.topRanked?.url {
            feedData.banner = topWebpageIcon
        }

        if feedData.image == nil && feedData.banner != nil {
            feedData.image = feedData.banner
        }

        if let description = source.description, description != "" {
            feedData.metaDescription = description.trimmingCharacters(in: .whitespacesAndNewlines)
        } else if let description = webpageMetadata?.description {
            feedData.metaDescription = description.trimmingCharacters(in: .whitespacesAndNewlines)
        }

        if let copyright = source.copyright, copyright != "" {
            feedData.copyright = copyright.trimmingCharacters(in: .whitespacesAndNewlines)
        } else if let copyright = webpageMetadata?.copyright {
            feedData.copyright = copyright.trimmingCharacters(in: .whitespacesAndNewlines)
        }
    }
}
