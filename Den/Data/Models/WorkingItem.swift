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
final class WorkingItem: ImageSelection {
    var id: UUID?
    var ingested: Date?
    var link: URL?
    var published: Date?
    var summary: String?
    var title: String?

    public func ingest(_ item: AtomFeedEntry?) {
        guard let item = item else { return }
        let transform = AtomItemTransform(workingItem: self, entry: item)
        transform.apply()
    }

    public func ingest(_ item: RSSFeedItem?) {
        guard let item = item else { return }
        let transform = RSSItemTransform(workingItem: self, rssItem: item)
        transform.apply()
    }

    public func ingest(_ item: JSONFeedItem?) {
        guard let item = item else { return }
        let transform = JSONItemTransform(workingItem: self, jsonItem: item)
        transform.apply()
    }
}
