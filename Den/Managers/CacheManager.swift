//
//  CacheManager.swift
//  Den
//
//  Created by Garrett Johnson on 8/8/20.
//  Copyright © 2020 Garrett Johnson. All rights reserved.
//

import Foundation
import CoreData
import URLImage

class CacheManager: ObservableObject {
    
    private var persistentContainer: NSPersistentContainer
    
    init(persistentContainer: NSPersistentContainer) {
        self.persistentContainer = persistentContainer
    }
    
    func clearAll() {
        resetFeeds()
        clearWebCaches()
    }
    
    func clearWebCaches() {
        URLImageService.shared.removeAllCachedImages()
        URLCache.shared.removeAllCachedResponses()
    }
    
    func resetFeeds() {
        // Reset feed meta data and remove items
        do {
            let feeds = try self.persistentContainer.viewContext.fetch(Feed.fetchRequest()) as! [Feed]
            feeds.forEach { feed in
                feed.itemsArray.forEach { item in
                    self.persistentContainer.viewContext.delete(item)
                }
                feed.refreshed = nil
                feed.favicon = nil
            }
        } catch {
            fatalError("Unable to fetch items: \(error)")
        }
        
        // Save context to apply changes to Core Data
        do {
            try self.persistentContainer.viewContext.save()
        } catch {
            fatalError("Unable to save context after item cleanup: \(error)")
        }
        
        // Send object events on pages to update counts
        do {
            let pages = try self.persistentContainer.viewContext.fetch(Page.fetchRequest()) as! [Page]
            pages.forEach { page in
                page.objectWillChange.send()
            }
        } catch {
            fatalError("Unable to fetch pages: \(error)")
        }
    }
}
