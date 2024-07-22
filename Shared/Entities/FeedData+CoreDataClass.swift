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

@objc(FeedData)
final public class FeedData: NSManagedObject {
    enum RefreshError: String {
        case request
        case parsing
    }
    
    var wrappedError: RefreshError? {
        get {
            guard let error = error else { return nil }
            return RefreshError(rawValue: error)
        }
        set {
            error = newValue?.rawValue
        }
    }

    var feed: Feed? {
        guard let feedID = self.feedId else { return nil }
        
        let request = Feed.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", feedID as CVarArg)
        request.fetchLimit = 1
        
        return try? self.managedObjectContext?.fetch(request).first
    }

    var itemsArray: [Item] {
        items?.sortedArray(using: [
            NSSortDescriptor(key: "published", ascending: false),
            NSSortDescriptor(key: "title", ascending: true)
        ]) as? [Item] ?? []
    }

    static func create(in managedObjectContext: NSManagedObjectContext, feedId: UUID) -> FeedData {
        let newFeed = self.init(context: managedObjectContext)
        newFeed.id = UUID()
        newFeed.feedId = feedId

        return newFeed
    }
}
