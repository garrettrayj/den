//
//  Page+CoreDataClass.swift
//  Den
//
//  Created by Garrett Johnson on 7/30/20.
//  Copyright © 2020 Garrett Johnson. All rights reserved.
//

import Foundation
import CoreData

@objc(Page)
public class Page: NSManagedObject {
    public var wrappedName: String {
        get { name ?? "Untitled" }
        set { name = newValue }
    }
    
    public var wrappedItemsPerFeed: Int {
        get { Int(itemsPerFeed) }
        set { itemsPerFeed = Int16(newValue) }
    }
    
    public var unreadCount: Int {
        get {            
            feedsArray.reduce(0) { (result, feed) -> Int in
                result + min(self.wrappedItemsPerFeed, feed.unreadItemCount)
            }
        }
    }
    
    public var feedsArray: [Feed] {
        get {
            guard let feeds = self.feeds else { return [] }
            return feeds.sortedArray(using: [NSSortDescriptor(key: "userOrder", ascending: true)]) as! [Feed]
        }
        set {
            feeds = NSSet(array: newValue)
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
        feedsArray.sorted { a, b in
            if let aRefreshed = a.refreshed,
               let bRefreshed = b.refreshed {
                return aRefreshed < bRefreshed
            }
            return false
        }.first?.refreshed
    }
    
    static func create(in managedObjectContext: NSManagedObjectContext) -> Page {
        do {
            let pages = try managedObjectContext.fetch(Page.fetchRequest())
            
            let newPage = self.init(context: managedObjectContext)
            newPage.id = UUID()
            newPage.userOrder = Int16(pages.count + 1)
            newPage.name = "New Page"
            newPage.itemsPerFeed = Int16(5)
            
            return newPage
        } catch {
            fatalError("Unable to create new page: \(error)")
        }
    }
}
