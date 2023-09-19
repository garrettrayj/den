//
//  Feed+CoreDataClass.swift
//  Den
//
//  Created by Garrett Johnson on 7/30/20.
//  Copyright © 2020 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import CoreData
import FeedKit
import OSLog
import SwiftUI

public enum RefreshError: String {
    case request
    case parsing
}

@objc(FeedData)
public class FeedData: NSManagedObject {
    public var wrappedError: RefreshError? {
        guard let error = error else { return nil }
        return RefreshError(rawValue: error)
    }

    public var feed: Feed? {
        if let unwrappedValues = value(forKey: "feed") as? [Feed] {
            return unwrappedValues.first
        }

        return nil
    }

    public var itemsArray: [Item] {
        items?.sortedArray(
            using: [NSSortDescriptor(key: "published", ascending: false)]
        ) as? [Item] ?? []
    }

    public var responseTimeString: String {
        responseTime > 0 ? String(responseTime) : "NA"
    }

    static func create(in managedObjectContext: NSManagedObjectContext, feedId: UUID) -> FeedData {
        let newFeed = self.init(context: managedObjectContext)
        newFeed.id = UUID()
        newFeed.feedId = feedId

        return newFeed
    }
}
