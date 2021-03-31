//
//  Feed+CoreDataClass.swift
//  Den
//
//  Created by Garrett Johnson on 7/30/20.
//  Copyright © 2020 Garrett Johnson. All rights reserved.
//

import Foundation
import CoreData
import FeedKit
import OSLog

@objc(Feed)
public class Feed: NSManagedObject {
    public var subscription: Subscription? {
        let values = value(forKey: "subscription") as! [Subscription]
        return values.first
    }
    
    public var itemsArray: [Item] {
        guard let items = items else {
            return []
        }
        
        return items.sortedArray(
            using: [NSSortDescriptor(key: "published", ascending: false)]
        ) as! [Item]
    }
    

    public var unreadItemCount: Int {
        itemsArray.filter { item in item.read == false }.count
    }
    
    public var itemsWithImageCount: Int {
        itemsArray.filter({ item in
            item.image != nil
        }).count
    }
    
    static func create(in managedObjectContext: NSManagedObjectContext, subscriptionId: UUID) -> Feed {
        let newFeed = self.init(context: managedObjectContext)
        newFeed.id = UUID()
        newFeed.subscriptionId = subscriptionId
        
        return newFeed
    }
    
    /**
     Atom feed handler responsible for populating application data model from FeedKit AtomFeed result.
     */
    public func ingest(content: AtomFeed, moc managedObjectContext: NSManagedObjectContext) {
        guard let subscription = self.subscription else { return }
        
        if subscription.title == nil {
            if let feedTitle = content.title?.trimmingCharacters(in: .whitespacesAndNewlines) {
                subscription.title = feedTitle
            }
        }
        
        if self.link == nil {
            if
                let atomLink = content.links?.first(where: { atomLink in
                    atomLink.attributes?.rel == "alternate" || atomLink.attributes?.rel == nil
                }),
                let homepageURL = atomLink.attributes?.href
            {
                self.link = URL(string: homepageURL)
            }
        }
        
        guard
            let atomEntries = content.entries,
            let itemsPerFeed = subscription.page?.wrappedItemsPerFeed
        else { return }
        
        atomEntries.prefix(itemsPerFeed).forEach { atomEntry in
            // Continue if link is missing
            guard let itemLink = atomEntry.linkURL else {
                Logger.ingest.notice("Missing link for Atom entry: \(atomEntry.title ?? "Untitled")")
                return
            }
            
            // Continue if item already exists
            if (self.itemsArray.contains(where: { item in item.link == itemLink })) {
                return
            }
            
            let newItem = Item.create(atomEntry: atomEntry, moc: managedObjectContext, feed: self)
            self.addToItems(newItem)
        }
        
        // Cleanup items not present in feed
        self.itemsArray.forEach({ item in
            if (
                atomEntries.contains(where: { feedItem in
                    guard let atomEntryAlternateLink = feedItem.linkURL else {
                        return false
                    }
                    
                    return item.link == atomEntryAlternateLink
                }) == false
            ) {
                self.removeFromItems(item)
                managedObjectContext.delete(item)
            }
        })
    }
    
    /**
     RSS feed handler responsible for populating application data model from FeedKit RSSFeed result.
     */
    public func ingest(content: RSSFeed, moc managedObjectContext: NSManagedObjectContext) {
        guard let subscription = self.subscription else { return }
        
        if subscription.title == nil {
            if let feedTitle = content.title?.trimmingCharacters(in: .whitespacesAndNewlines) {
                subscription.title = feedTitle
            }
        }
        
        if self.link == nil {
            if let homepage = content.link?.trimmingCharacters(in: .whitespacesAndNewlines), let homepageURL = URL(string: homepage) {
                self.link = homepageURL
            }
        }
        
        guard
            let rssItems = content.items,
            let itemsPerFeed = subscription.page?.wrappedItemsPerFeed
        else { return }
        
        // Add new items
        rssItems.prefix(itemsPerFeed).forEach { (rssItem: RSSFeedItem) in
            guard let itemLink = rssItem.linkURL else {
                Logger.ingest.notice("Missing link for RSS item: \(rssItem.title ?? "Untitled")")
                return
            }
            
            // Continue if item already exists
            if (self.itemsArray.contains(where: { item in item.link == itemLink})) {
                return
            }
            
            let newItem = Item.create(rssItem: rssItem, moc: managedObjectContext, feed: self)
            self.addToItems(newItem)
        }
        
        // Cleanup items not present in feed
        self.itemsArray.forEach({ item in
            if (
                rssItems.contains(where: { (feedItem) -> Bool in
                    guard let feedItemLink = feedItem.linkURL else { return false }
                    return item.link == feedItemLink
                }) == false
            ) {
                self.removeFromItems(item)
                managedObjectContext.delete(item)
            }
        })
    }
    
    func ingest(content: JSONFeed, moc managedObjectContext: NSManagedObjectContext) {
        guard let subscription = self.subscription else { return }
        
        if subscription.title == nil {
            if let title = content.title?.trimmingCharacters(in: .whitespacesAndNewlines) {
                subscription.title = title
            }
        }
        
        if let link = content.webpage {
            self.link = link
        }
        
        guard
            let jsonItems = content.items,
            let itemsPerFeed = subscription.page?.wrappedItemsPerFeed
        else { return }
        
        // Add new items
        jsonItems.prefix(itemsPerFeed).forEach { jsonItem in
            guard let itemLink = jsonItem.linkURL else {
                Logger.ingest.notice("Missing link for JSON item: \(jsonItem.title ?? "Untitled")")
                return
            }
            
            // Continue if item already exists
            if (self.itemsArray.contains(where: { item in item.link == itemLink})) {
                return
            }
            
            let newItem = Item.create(jsonItem: jsonItem, moc: managedObjectContext, feed: self)
            self.addToItems(newItem)
        }
        
        // Cleanup items not present in feed
        self.itemsArray.forEach({ item in
            if (
                jsonItems.contains(where: { (feedItem) -> Bool in
                    guard let feedItemLink = feedItem.linkURL else { return false }
                    return item.link == feedItemLink
                }) == false
            ) {
                managedObjectContext.delete(item)
                self.removeFromItems(item)
            }
        })
    }
}
