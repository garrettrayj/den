//
//  WorkingFeed.swift
//  Den
//
//  Created by Garrett Johnson on 4/3/21.
//  Copyright © 2021 Garrett Johnson. All rights reserved.
//

import Foundation
import OSLog

import FeedKit

/**
 Feed entity representation for working with data outside of NSManagedObjectContext (e.g. feed ingest operations)
 */
final class WorkingFeedData: ImageSelection {
    var error: String?
    var favicon: URL?
    var httpStatus: Int?
    var id: UUID?
    var link: URL?
    var metaFetched: Date?
    var refreshed: Date?
    var feedId: UUID?
    var title: String?

    /**
     Atom feed handler responsible for populating application data model from FeedKit AtomFeed result.
     */
    func ingest(content: AtomFeed) {
        if let feedTitle = content.title {
            title = feedTitle.strippingTags().preparingTitle()
        }

        link = content.webpage

        if
            let urlString = content.icon,
            let url = URL(string: urlString, relativeTo: link)
        {
            favicon = url
        }

        if
            let urlString = content.logo,
            let url = URL(string: urlString, relativeTo: link)
        {
            imagePool.append(RankedImage(url: url, rank: 2))
        }
    }

    /**
     RSS feed handler responsible for populating application data model from FeedKit RSSFeed result.
     */
    func ingest(content: RSSFeed) {
        if let feedTitle = content.title {
            title = feedTitle.preparingTitle()
        }

        link = content.webpage

        if
            let urlString = content.image?.url,
            let url = URL(string: urlString, relativeTo: link)
        {
            imagePool.append(RankedImage(
                url: url,
                rank: 2,
                width: content.image?.width,
                height: content.image?.height
            ))
        }
    }

    /**
     JSON feed handler responsible for populating application data model from FeedKit JSONFeed result.
     */
    func ingest(content: JSONFeed) {
        if let feedTitle = content.title {
            title = feedTitle.preparingTitle()
        }

        link = content.webpage

        if
            let urlString = content.favicon,
            let url = URL(string: urlString, relativeTo: link)
        {
            favicon = url
        }

        if
            let urlString = content.icon,
            let url = URL(string: urlString, relativeTo: link)
        {
            imagePool.append(RankedImage(
                url: url,
                rank: 2
            ))
        }
    }
}
