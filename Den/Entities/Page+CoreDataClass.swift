//
//  Page+CoreDataClass.swift
//  Den
//
//  Created by Garrett Johnson on 7/30/20.
//  Copyright © 2020 Garrett Johnson. All rights reserved.
//

import CoreData

@objc(Page)
public class Page: NSManagedObject {
    public var displayName: String {
        name == nil || name == "" ? "Untitled" : name!
    }

    public var wrappedName: String {
        get { name ?? "Untitled" }
        set { name = newValue }
    }

    public var wrappedSymbol: String {
        get { symbol ?? "square.grid.2x2" }
        set { symbol = newValue }
    }

    public var wrappedItemsPerFeed: Int {
        get { Int(itemsPerFeed) }
        set { itemsPerFeed = Int16(newValue) }
    }

    public var unreadCount: Int {
        feedsArray.reduce(0) { (result, feed) -> Int in
            if let feedData = feed.feedData {
                return result + feedData.limitedItemsArray
                    .filter { item in item.read == false }.count
            }

            return result + 0
        }
    }

    public var feedsArray: [Feed] {
        get {
            guard
                let feeds = self.feeds?.sortedArray(
                    using: [NSSortDescriptor(key: "userOrder", ascending: true)]
                ) as? [Feed]
            else { return [] }

            return feeds
        }
        set {
            feeds = NSSet(array: newValue)
        }
    }

    public var insecureFeeds: [Feed] {
        feedsArray.filter { feed in
            feed.url?.scheme != "https"
        }
    }

    public var feedsUserOrderMin: Int16 {
        feedsArray.reduce(0) { (result, feed) -> Int16 in
            if feed.userOrder < result {
                return feed.userOrder
            }
            return result
        }
    }

    public var feedsUserOrderMax: Int16 {
        feedsArray.reduce(0) { (result, feed) -> Int16 in
            if feed.userOrder > result {
                return feed.userOrder
            }
            return result
        }
    }

    public var minimumRefreshedDate: Date? {
        feedsArray.sorted { aFeed, bFeed in
            if let aRefreshed = aFeed.feedData?.refreshed,
               let bRefreshed = bFeed.feedData?.refreshed {
                return aRefreshed < bRefreshed
            }
            return false
        }.first?.feedData?.refreshed
    }

    public var limitedItemsArray: [Item] {
        let items: NSMutableSet = []

        feedsArray.forEach { feed in
            guard let feedData = feed.feedData else { return }
            items.union(Set(feedData.limitedItemsArray))
        }

        return items.sortedArray(
            using: [
                NSSortDescriptor(key: "published", ascending: false),
                NSSortDescriptor(key: "ingested", ascending: false)
            ]
        ) as? [Item] ?? []
    }

    static func create(in managedObjectContext: NSManagedObjectContext, profile: Profile) -> Page {
        let newPage = self.init(context: managedObjectContext)
        newPage.id = UUID()
        newPage.profile = profile
        newPage.userOrder = Int16(profile.pagesUserOrderMax + 1)
        newPage.name = "New Page"
        newPage.itemsPerFeed = Int16(4)

        return newPage
    }
}
