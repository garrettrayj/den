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
import OSLog

class CacheManager: ObservableObject {
    private var viewContext: NSManagedObjectContext
    
    init(persistenceManager: PersistenceManager) {
        self.viewContext = persistenceManager.container.viewContext
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
        do {
            let pages = try viewContext.fetch(Page.fetchRequest()) as! [Page]
            pages.forEach { page in
                page.subscriptionsArray.forEach { subscription in
                    
                    if let feed = subscription.feed {
                        feed.itemsArray.forEach { item in
                            viewContext.delete(item)
                        }
                        feed.refreshed = nil
                        feed.favicon = nil
                    }
                }
                page.objectWillChange.send()
            }
        } catch let error as NSError {
            Logger.main.info("Error occured while resetting pages. \(error)")
        }
        
        do {
            try viewContext.save()
        } catch let error as NSError {
            CrashManager.shared.handleCriticalError(error)
        }
    }
}
