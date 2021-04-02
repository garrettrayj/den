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
    struct FeedIngestMeta {
        var thumbnails: [URL] = []
    }
    
    public var subscription: Subscription? {
        let values = value(forKey: "subscription") as? [Subscription]
        if let unwrappedValues = values {
            return unwrappedValues.first
        }
        
        return nil
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
    func ingest(content: AtomFeed, moc managedObjectContext: NSManagedObjectContext) -> FeedIngestMeta {
        var ingestMeta = FeedIngestMeta()
        
        guard let subscription = self.subscription else { return ingestMeta }
        
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
        else { return ingestMeta }
        
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
            
            let newItem = Item.create(moc: managedObjectContext, feed: self)
            newItem.ingest(atomEntry)
            
            if let thumbnail = newItem.image {
                ingestMeta.thumbnails.append(thumbnail)
            }
        }
        
        return ingestMeta
    }
    
    /**
     RSS feed handler responsible for populating application data model from FeedKit RSSFeed result.
     */
    func ingest(content: RSSFeed, moc managedObjectContext: NSManagedObjectContext) -> FeedIngestMeta {
        var ingestMeta = FeedIngestMeta()
        
        guard let subscription = self.subscription else { return ingestMeta }
        
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
        else { return ingestMeta }
        
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
            
            let newItem = Item.create(moc: managedObjectContext, feed: self)
            newItem.ingest(rssItem)
            
            if let thumbnail = newItem.image {
                ingestMeta.thumbnails.append(thumbnail)
            }
        }
        
        return ingestMeta
    }
    
    func ingest(content: JSONFeed, moc managedObjectContext: NSManagedObjectContext) -> FeedIngestMeta {
        var ingestMeta = FeedIngestMeta()
        
        guard let subscription = self.subscription else { return ingestMeta }
        
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
        else { return ingestMeta }
        
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
            
            let newItem = Item.create(moc: managedObjectContext, feed: self)
            newItem.ingest(jsonItem)
            
            if let thumbnail = newItem.image {
                ingestMeta.thumbnails.append(thumbnail)
            }
        }
        
        return ingestMeta
    }
}
