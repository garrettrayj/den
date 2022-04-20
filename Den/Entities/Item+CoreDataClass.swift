//
//  Item+CoreDataClass.swift
//  Den
//
//  Created by Garrett Johnson on 7/30/20.
//  Copyright © 2020 Garrett Johnson. All rights reserved.
//

import CoreData
import HTMLEntities
import SwiftUI
import OSLog

@objc(Item)
public class Item: NSManagedObject {
    public var read: Bool {
        guard let values = value(forKey: "history") as? [History] else { return false }
        return !values.isEmpty
    }

    @objc
    public var feedTitle: String {
        feedData?.feed?.wrappedTitle ?? "Untitled"
    }

    public var wrappedTitle: String {
        get {title ?? "Untitled"}
        set {title = newValue}
    }

    public var imageAspectRatio: CGFloat? {
        guard imageWidth > 0, imageHeight > 0 else { return nil }
        return CGFloat(imageWidth) / CGFloat(imageHeight)
    }

    static func create(moc managedObjectContext: NSManagedObjectContext, feedData: FeedData) -> Item {
        let item = Item.init(context: managedObjectContext)
        item.id = UUID()
        item.feedData = feedData

        return item
    }
}
