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
    public var history: [History]? {
        value(forKey: "history") as? [History]
    }

    public var read: Bool {
        guard let history = history else { return false }
        return !history.isEmpty
    }

    @objc
    public var feedTitle: String {
        feedData?.feed?.wrappedTitle ?? "Untitled"
    }

    @objc
    public var day: String {
        published?.fullNoneDisplay() ?? "N/A"
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

extension Array where Element == Item {
    func read() -> [Item] {
        self.filter { item in
            item.read == true
        }
    }

    func unread() -> [Item] {
        self.filter { item in
            item.read == false
        }
    }
}
