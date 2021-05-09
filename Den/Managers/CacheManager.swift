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
    private var persistentContainer: NSPersistentContainer
    private var crashManager: CrashManager
    private var lastBackgroundCleanup: Date?
    
    init(persistenceManager: PersistenceManager, crashManager: CrashManager) {
        self.persistentContainer = persistenceManager.container
        self.crashManager = crashManager
    }
    
    func resetFeeds() {
        let context: NSManagedObjectContext = self.persistentContainer.newBackgroundContext()
        context.undoManager = nil
        context.performAndWait {
            do {
                let pages = try context.fetch(Page.fetchRequest()) as! [Page]
                pages.forEach { page in
                    page.feedsArray.forEach { feed in
                        if let feedData = feed.feedData {
                            feedData.itemsArray.forEach { item in
                                context.delete(item)
                            }
                            feedData.refreshed = nil
                            feedData.favicon = nil
                            feedData.faviconFile = nil
                            feedData.metaFetched = nil
                        }
                    }
                }
                
                if context.hasChanges {
                    do {
                        try context.save()
                        
                        DispatchQueue.main.async {
                            do {
                                try self.persistentContainer.viewContext.fetch(Page.fetchRequest()).forEach { page in
                                    page.objectWillChange.send()
                                }
                            } catch {
                                
                            }
                        }
                    } catch {
                        DispatchQueue.main.async {
                            self.crashManager.handleCriticalError(error as NSError)
                        }
                    }
                }
            } catch let error as NSError {
                Logger.main.info("Error occured while resetting pages. \(error)")
            }
        }
    }
    
    func performBackgroundCleanup() {
        if let cleanupDate = lastBackgroundCleanup, cleanupDate > Date(timeIntervalSinceNow: -24 * 60 * 60) { return }
        guard let faviconsDirectory = FileManager.default.faviconsDirectory else { return }
        guard let thumbnailsDirectory = FileManager.default.thumbnailsDirectory else { return }
        
        var cleanFeeds: [FeedData] = []
        
        let context: NSManagedObjectContext = self.persistentContainer.newBackgroundContext()
        context.undoManager = nil
        context.performAndWait {
            do {
                let feedDatas = try context.fetch(FeedData.fetchRequest()) as! [FeedData]
                
                for feedData in feedDatas {
                    if feedData.feed == nil {
                        context.delete(feedData)
                        return
                    }
                    
                    guard let itemLimit = feedData.feed?.page?.wrappedItemsPerFeed else { return }
                    
                    if feedData.itemsArray.count > itemLimit {
                        let oldItems = feedData.itemsArray.suffix(from: itemLimit)
                        oldItems.forEach { context.delete($0) }
                    }
                    
                    cleanFeeds.append(feedData)
                }
                
                let activeFavicons: [URL] = cleanFeeds.compactMap { feed in
                    if let filename = feed.faviconFile {
                        return faviconsDirectory.appendingPathComponent(filename)
                    }
                    return nil
                }
                self.cleanupCacheDirectory(cacheDirectory: faviconsDirectory, activeFileList: activeFavicons)
                
                
                let items: [Item] = cleanFeeds.flatMap { $0.itemsArray }
                let activeThumbnails: [URL] = items.compactMap { item in
                    if let filename = item.imageFile {
                        return thumbnailsDirectory.appendingPathComponent(filename)
                    }
                    return nil
                }
                self.cleanupCacheDirectory(cacheDirectory: thumbnailsDirectory, activeFileList: activeThumbnails)
                
                if context.hasChanges {
                    do {
                        try context.save()
                    } catch {
                        DispatchQueue.main.async {
                            self.crashManager.handleCriticalError(error as NSError)
                        }
                    }
                }
            } catch let error as NSError {
                Logger.main.info("Error occured fetching feeds for item cleanup. \(error)")
            }
        }
        
        lastBackgroundCleanup = Date()
        Logger.main.info("Finished cleaning up databases and files.")
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
