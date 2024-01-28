//
//  AtomFeedMetaUpdate.swift
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

struct AtomFeedMetaUpdate {
    let feedData: FeedData
    let source: AtomFeed
    let webpageMetadata: WebpageMetadata.Results?

    // swiftlint:disable cyclomatic_complexity
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
        } else if let topWebpageIcon = webpageMetadata?.icons.topRanked?.url {
            feedData.banner = topWebpageIcon
        }

        if feedData.image == nil && feedData.banner != nil {
            feedData.image = feedData.banner
        }

        if let subtitle = source.subtitle?.value, subtitle != "" {
            feedData.metaDescription = subtitle.trimmingCharacters(in: .whitespacesAndNewlines)
        } else if let description = webpageMetadata?.description {
            feedData.metaDescription = description.trimmingCharacters(in: .whitespacesAndNewlines)
        }

        if let copyright = source.rights, copyright != "" {
            feedData.copyright = copyright.trimmingCharacters(in: .whitespacesAndNewlines)
        } else if let copyright = webpageMetadata?.copyright {
            feedData.copyright = copyright.trimmingCharacters(in: .whitespacesAndNewlines)
        }
    }
    // swiftlint:enable cyclomatic_complexity
}
