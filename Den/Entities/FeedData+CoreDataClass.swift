//
//  Feed+CoreDataClass.swift
//  Den
//
//  Created by Garrett Johnson on 7/30/20.
//  Copyright © 2020 Garrett Johnson. All rights reserved.
//

import CoreData
import FeedKit
import OSLog
import SwiftUI

@objc(FeedData)
public class FeedData: NSManagedObject {
    struct FeedIngestMeta {
        var thumbnails: [URL] = []
    }

    public var feed: Feed? {
        let values = value(forKey: "feed") as? [Feed]
        if let unwrappedValues = values {
            return unwrappedValues.first
        }

        return nil
    }

    public var itemsArray: [Item] {
        guard
            let items = items?.sortedArray(
                using: [NSSortDescriptor(key: "published", ascending: false)]
            ) as? [Item]
        else { return [] }

        return items
    }

    public var previewItems: [Item] {
        Array(itemsArray.prefix(feed?.wrappedItemLimit ?? Int(ContentLimits.itemLimitDefault)))
    }

    public var linkDisplayString: String? {
        guard let link = link else { return nil }

        return link.absoluteString
            .replacingOccurrences(of: "http://", with: "")
            .replacingOccurrences(of: "https://", with: "")
            .trimmingCharacters(in: .init(charactersIn: "/"))
    }

    static func create(in managedObjectContext: NSManagedObjectContext, feedId: UUID) -> FeedData {
        let newFeed = self.init(context: managedObjectContext)
        newFeed.id = UUID()
        newFeed.feedId = feedId

        return newFeed
    }
}
