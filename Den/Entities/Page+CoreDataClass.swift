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
                return result + feedData.itemsArray
                    .prefix(wrappedItemsPerFeed)
                    .filter { item in item.read == false }.count
            } else {
                return 0
            }
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

    static func create(in managedObjectContext: NSManagedObjectContext, profile: Profile) -> Page {
        do {
            let pages = try managedObjectContext.fetch(Page.fetchRequest())

            let newPage = self.init(context: managedObjectContext)
            newPage.id = UUID()
            newPage.profile = profile
            newPage.userOrder = Int16(pages.count + 1)
            newPage.name = "New Page"
            newPage.itemsPerFeed = Int16(4)

            return newPage
        } catch {
            fatalError("Unable to create new page: \(error)")
        }
    }
}

extension Collection where Element == Page, Index == Int {
    func delete(at indices: IndexSet, from managedObjectContext: NSManagedObjectContext) {
        indices.forEach { managedObjectContext.delete(self[$0]) }

        do {
            try managedObjectContext.save()
        } catch {
            // Replace this implementation with code to handle the error appropriately.
            // fatalError() causes the application to generate a crash log and terminate.
            // You should not use this function in a shipping application,
            // although it may be useful during development.
            let nserror = error as NSError
            fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
        }
    }
}
