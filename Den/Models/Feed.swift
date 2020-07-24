//
//  Feed.swift
//  Den
//
//  Created by Garrett Johnson on 6/1/20.
//  Copyright © 2020 Garrett Johnson. All rights reserved.
//

import SwiftUI
import CoreData
import FeedKit
import SwiftSoup

extension Feed: Identifiable {
    public var itemsArray: [Item] {
        guard let items = items else {
            return []
        }
        
        return items.sortedArray(
            using: [NSSortDescriptor(key: "published", ascending: false)]
        ) as! [Item]
    }
    
    public var urlString: String {
        get{url?.absoluteString ?? ""}
        set{url = URL(string: newValue)}
    }
    
    public var wrappedTitle: String {
        get{title ?? "Untitled"}
        set{title = newValue}
    }
    
    public var unreadItemCount: Int {
        itemsArray.prefix(Int(itemLimit)).filter({ item in
            item.read == false
        }).count
    }
    
    public var itemsWithImageCount: Int {
        itemsArray.filter({ item in
            item.image != nil
        }).count
    }
    
    static func create(in managedObjectContext: NSManagedObjectContext, page: Page?) -> Feed {
        let newFeed = self.init(context: managedObjectContext)
        newFeed.id = UUID()
        newFeed.itemLimit = 5
        newFeed.showLargePreviews = false
        newFeed.showThumbnails = true
        newFeed.page = page
        
        return newFeed
    }
    
    func handleResult(_ result: Result<FeedKit.Feed, ParserError>) {
        switch result {
        case .success(let content):
            switch content {
                case let .atom(content):
                    self.populate(content)
                case let .rss(content):
                    self.populate(content)
                case let .json(content):
                    self.populate(content)
            }
        case .failure(let error):
            print(error)
        }
    }
    
    /**
     Atom feed handler responsible for populating application data model from FeedKit AtomFeed result.
     */
    private func populate(_ content: AtomFeed) {
        if title == nil {
            if let feedTitle = content.title?.trimmingCharacters(in: .whitespacesAndNewlines) {
                self.title = feedTitle
            }
        }
        
        if link == nil {
            if
                let atomLink = content.links?.first(where: { atomLink in
                    atomLink.attributes?.rel == "alternate" || atomLink.attributes?.rel == nil
                }),
                let homepageURL = atomLink.attributes?.href
            {
                self.link = URL(string: homepageURL)
            }
        }
        
        guard let atomEntries = content.entries else {
            // TODO: HANDLE MISSING ATOM ENTRIES
            return
        }
        
        atomEntries.prefix(10).forEach { (atomEntry: AtomFeedEntry) in
            // Continue if link is missing
            guard let itemLink = atomEntry.linkURL else {
                print("MISSING LINK")
                return
            }
            
            // Continue if item already exists
            if (self.itemsArray.contains(where: { item in item.link == itemLink })) {
                return
            }
            
            do {
                try self.mutableSetValue(forKey: "items").add(Item.create(in: self.managedObjectContext!, atomEntry: atomEntry))
            } catch {
                print("Error creating item from Atom entry. \(error)")
            }
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
                print("Cleaning up item \(item.title ?? "Untitled")...")
                self.managedObjectContext?.delete(item)
            }
        })
    }
    
    /**
     RSS feed handler responsible for populating application data model from FeedKit RSSFeed result.
     */
    private func populate(_ content: RSSFeed) {
        if title == nil {
            if let feedTitle = content.title?.trimmingCharacters(in: .whitespacesAndNewlines) {
                self.title = feedTitle
            }
        }
        
        if link == nil {
            if let homepage = content.link?.trimmingCharacters(in: .whitespacesAndNewlines), let homepageURL = URL(string: homepage) {
                self.link = homepageURL
            }
        }
        
        guard let rssItems = content.items else {
            // TODO: HANDLE MISSING ITEMS
            return
        }
        
        // Add new items
        rssItems.prefix(10).forEach { (rssItem: RSSFeedItem) in
            guard let itemLink = rssItem.linkURL else {
                print("RSS ITEM MISSING LINK")
                return
            }
            
            // Continue if item already exists
            if (self.itemsArray.contains(where: { item in item.link == itemLink})) {
                return
            }
            
            do {
                try self.mutableSetValue(forKey: "items").add(Item.create(in: self.managedObjectContext!, rssItem: rssItem))
            } catch {
                print("Error creating RSS item. \(error)")
            }
        }
        
        // Cleanup items not present in feed
        self.itemsArray.forEach({ item in
            if (
                rssItems.contains(where: { (feedItem) -> Bool in
                    guard let feedItemLink = feedItem.linkURL else { return false }
                    return item.link == feedItemLink
                }) == false
            ) {
                self.managedObjectContext?.delete(item)
            }
        })
    }
    
    /**
     TODO: JSON Feed importer
     */
    private func populate(_ content: JSONFeed) {
        self.title = content.title
    }
    
    /**
     Fetch homepage link and extract relevant metadata from HTML source
     */
    func fetchMetadata() {
        // Skip if Feed isn't new
        if !self.objectID.isTemporaryID { return }

        guard let webpageURL = link else { return }
        
        let wrangler = WebpageMetaWrangler(webpageURL: webpageURL)
        wrangler.getFavicon { (favicon, error) in
            self.favicon = favicon
        }
    }
}

extension Collection where Element == Feed, Index == Int {
    func delete(at indices: IndexSet, from managedObjectContext: NSManagedObjectContext) {
        indices.forEach { managedObjectContext.delete(self[$0]) }
 
        do {
            try managedObjectContext.save()
        } catch {
            // Replace this implementation with code to handle the error appropriately.
            // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            let nserror = error as NSError
            fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
        }
    }
}
