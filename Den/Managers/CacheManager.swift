//
//  CacheManager.swift
//  Den
//
//  Created by Garrett Johnson on 8/8/20.
//  Copyright © 2020 Garrett Johnson. All rights reserved.
//

import Foundation
import CoreData
import OSLog

class CacheManager: ObservableObject {
    private var viewContext: NSManagedObjectContext
    private var lastBackgroundCleanup: Date?
    
    init(persistenceManager: PersistenceManager) {
        self.viewContext = persistenceManager.container.viewContext
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
                        feed.metaFetched = nil
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
    
    func performBackgroundCleanup() {
        if let cleanupDate = lastBackgroundCleanup, cleanupDate > Date(timeIntervalSinceNow: -4 * 60 * 60) {
            return
        }
        
        self.cleanupItems()
        self.cleanupThumbnails()
        self.cleanupFavicons()
        
        lastBackgroundCleanup = Date()
        Logger.main.info("Finished cleaning up feed items and images.")
    }
    
    func cleanupItems() {
        do {
            let feeds = try viewContext.fetch(Feed.fetchRequest()) as! [Feed]
            for feed in feeds {
                guard let itemLimit = feed.subscription?.page?.wrappedItemsPerFeed else { return }
                let oldItems = feed.itemsArray.suffix(from: itemLimit)
                oldItems.forEach { viewContext.delete($0) }
            }
        } catch let error as NSError {
            Logger.main.info("Error occured fetching feeds for item cleanup. \(error)")
        }
        
        do {
            try viewContext.save()
        } catch {
            Logger.main.error("Error while saving context after cleanup: \(error as NSError)")
        }
    }
    
    func cleanupFavicons() {
        guard let faviconsDirectory = FileManager.default.faviconsDirectory() else { return }
        var activeFaviconFileList: [URL] = []

        do {
            let feeds = try viewContext.fetch(Feed.fetchRequest()) as! [Feed]
            activeFaviconFileList = feeds.compactMap { feed in
                if let localUrl = feed.faviconLocal {
                    return localUrl
                }
                
                return nil
            }
        } catch let error as NSError {
            Logger.main.info("Error occured fetching feeds for favicon cleanup. \(error)")
        }
        
        self.cleanupCacheDirectory(cacheDirectory: faviconsDirectory, activeFileList: activeFaviconFileList)
    }
    
    func cleanupThumbnails() {
        guard let thumbnailsDirectory = FileManager.default.thumbnailsDirectory() else { return }
        var activeFaviconFileList: [URL] = []

        do {
            let items = try viewContext.fetch(Item.fetchRequest()) as! [Item]
            activeFaviconFileList = items.compactMap { item in
                if let localUrl = item.imageLocal {
                    return localUrl
                }
                
                return nil
            }
        } catch let error as NSError {
            Logger.main.info("Error occured fetching feeds for favicon cleanup. \(error)")
        }
        
        self.cleanupCacheDirectory(cacheDirectory: thumbnailsDirectory, activeFileList: activeFaviconFileList)
    }
    
    func cleanupCacheDirectory(cacheDirectory: URL, activeFileList: [URL]) {
        let resourceKeys: [URLResourceKey] = [.creationDateKey, .isDirectoryKey]
        let enumerator = FileManager.default.enumerator(at: cacheDirectory, includingPropertiesForKeys: resourceKeys)!

        for case let fileUrl as URL in enumerator {
            do {
                let resourceValues = try fileUrl.resourceValues(forKeys: Set(resourceKeys))
                if resourceValues.isDirectory! { return }
            } catch {
                Logger.main.error("Unable to fetch file resource values: \(error as NSError)")
                return
            }
            
            if !activeFileList.contains(fileUrl) {
                do {
                    try FileManager.default.removeItem(at: fileUrl)
                } catch {
                    Logger.main.error("Unable to remove file: \(error as NSError)")
                }
            }
        }
    }
}
