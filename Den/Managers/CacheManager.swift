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
        clearItems()
        clearWebCaches()
    }
    
    func clearWebCaches() {
        URLCache.shared.removeAllCachedResponses()
        URLImageService.shared.resetFileCache()
    }
    
    func clearItems() {
        do {
            let items = try self.persistentContainer.viewContext.fetch(Item.fetchRequest()) as! [Item]
            items.forEach { item in
                self.persistentContainer.viewContext.delete(item)
            }
            
            do {
                try self.persistentContainer.viewContext.save()
            } catch {
                fatalError("Unable to save context after item cleanup: \(error)")
            }
        } catch {
            fatalError("Unable to fetch items: \(error)")
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
