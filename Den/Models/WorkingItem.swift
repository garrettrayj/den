//
//  WorkingFeedItem.swift
//  Den
//
//  Created by Garrett Johnson on 4/3/21.
//  Copyright © 2021 Garrett Johnson. All rights reserved.
//

import Foundation
import OSLog

import FeedKit

/**
 Item entity representation for working with data outside of NSManagedObjectContext (e.g. feed ingest operations)
 */
final class WorkingItem {
    var id: UUID?
    var image: URL?
    var imageWidth: Int32?
    var imageHeight: Int32?
    var imageFile: String?
    var imagePreview: String?
    var imageThumbnail: String?
    var ingested: Date?
    var link: URL?
    var published: Date?
    var summary: String?
    var title: String?

    public func ingest(_ atomEntry: AtomFeedEntry) {
        let transform = AtomItemTransform(workingItem: self, entry: atomEntry)
        transform.apply()
    }

    public func ingest(_ rssItem: RSSFeedItem) {
        let transform = RSSItemTransform(workingItem: self, rssItem: rssItem)
        transform.apply()
    }

    public func ingest(_ jsonItem: JSONFeedItem) {
        let transform = JSONItemTransform(workingItem: self, jsonItem: jsonItem)
        transform.apply()
    }
}
