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
final class WorkingFeedData {
    var error: String?
    var favicon: URL?
    var faviconFile: String?
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
        if let feedTitle = content.title?.trimmingCharacters(in: .whitespacesAndNewlines) {
            self.title = feedTitle
        }

        if
            let atomLink = content.links?.first(where: { atomLink in
                atomLink.attributes?.rel == "alternate" || atomLink.attributes?.rel == nil
            }),
            let homepageURL = atomLink.attributes?.href {
            self.link = URL(string: homepageURL)
        }
    }

    /**
     RSS feed handler responsible for populating application data model from FeedKit RSSFeed result.
     */
    func ingest(content: RSSFeed) {
        if let feedTitle = content.title?.trimmingCharacters(in: .whitespacesAndNewlines) {
            self.title = feedTitle
        }

        if
            let homepage = content.link?.trimmingCharacters(in: .whitespacesAndNewlines),
            let homepageURL = URL(string: homepage)
        {
            self.link = homepageURL
        }
    }

    /**
     JSON feed handler responsible for populating application data model from FeedKit JSONFeed result.
     */
    func ingest(content: JSONFeed) {
        if let title = content.title?.trimmingCharacters(in: .whitespacesAndNewlines) {
            self.title = title
        }

        if let link = content.webpage {
            self.link = link
        }
    }
}
