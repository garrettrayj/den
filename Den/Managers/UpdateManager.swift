//
//  UpdateManager.swift
//  Den
//
//  Created by Garrett Johnson on 7/29/20.
//  Copyright © 2020 Garrett Johnson. All rights reserved.
//

import Foundation
import SwiftUI
import CoreData
import FeedKit

class UpdateManager: ObservableObject {
    enum UpdateManagerError: Error {
        case invalidURL, fetchError
    }
    
    struct FeedResult {
        var feedObjectID: NSManagedObjectID
        var fetchError: Error?
        var parsedFeed: FeedKit.Feed?
        var parserError: FeedKit.ParserError?
        var fetchMeta: Bool = false
        var favicon: URL?
    }
    
    let saveBatchCount = ProcessInfo().activeProcessorCount
    
    @Published var updating: Bool = false
    
    var refreshable: Refreshable
    var viewContext: NSManagedObjectContext
    var managedObjectContext: NSManagedObjectContext
    var progress = Progress(totalUnitCount: 1)
    var queue = OperationQueue()
    var feedResults: [NSManagedObjectID: FeedResult] = [:]
    var operations: [Operation] = []
    var feedResultChunks: [[FeedResult]] = []

    init(refreshable: Refreshable, viewContext: NSManagedObjectContext) {
        self.refreshable = refreshable
        self.viewContext = viewContext
        
        self.managedObjectContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        managedObjectContext.parent = self.viewContext
        managedObjectContext.undoManager = nil
    }
    
    func update() {
        if updating == false {
            updating = true
        } else {
            print("Update manager already updating feeds")
            return
        }
        
        // Reset total progress units to number of fetch operations + one unit for completion operation + one unit for CoreData save
        let feedCount = Int64(refreshable.feedsArray.count)
        progress.totalUnitCount = feedCount + 1 + 1
        progress.completedUnitCount = 0
        
        DispatchQueue.global(qos: .userInitiated).async {
            self.operations = self.createOperations()
            self.queue.addOperations(self.operations, waitUntilFinished: true)
            
            // Bounce back to the main thread to setup private managed object context
            DispatchQueue.main.async {
                // Perform managed object update in background
                self.managedObjectContext.perform {
                    self.feedResultChunks = self.feedResults.valuesArray.chunked(into: 24) as! [[FeedResult]]
                    for feedResultChunk in self.feedResultChunks {
                        autoreleasepool {
                            for feedResult in feedResultChunk {
                                let feed = self.managedObjectContext.object(with: feedResult.feedObjectID) as! Feed
                                
                                if feedResult.fetchMeta == true {
                                    feed.favicon = feedResult.favicon
                                }
                                feed.refreshed = Date()
                                
                                switch feedResult.parsedFeed  {
                                    case let .atom(content):
                                        self.updateFeed(feed: feed, content: content, moc: self.managedObjectContext)
                                    case let .rss(content):
                                        self.updateFeed(feed: feed, content: content, moc: self.managedObjectContext)
                                    case let .json(content):
                                        self.updateFeed(feed: feed, content: content, moc: self.managedObjectContext)
                                    case .none:
                                        print("Fetch failed for \(feed.urlString)")
                                }
                            }
                        }
                        
                        do {
                            try self.managedObjectContext.save()
                            print("Successfully saved private context")
                        } catch {
                            fatalError("Failure to save private context: \(error)")
                        }
                    }
                    
                    // Jump back into main thread to save changes merged into parent managed object context (viewContext) and update UI
                    self.viewContext.performAndWait {
                        self.refreshable.onRefreshComplete()
                        do {
                            try self.viewContext.save()
                            print("Successfully saved view context")
                        } catch {
                            fatalError("Failure to save view context: \(error)")
                        }
                        
                        self.progress.completedUnitCount += 1
                        self.reset()
                        self.updating = false
                    }
                }
            }
        }
    }
    
    private func reset() {
        self.queue = OperationQueue()
        self.feedResults = [:]
        self.operations = []
        self.feedResultChunks = []
        self.managedObjectContext.reset()
    }
    
    private func createOperations() -> [Operation] {
        var fetchOperations: [FetchOperation] = []
        var parseOperations: [ParseOperation] = []
        var webpageOperations: [WebpageOperation] = []
        var metadataOperations: [MetadataOperation] = []
        var checkFaviconOperations: [CheckFaviconOperation] = []
        var faviconResultOperations: [FaviconResultOperation] = []
        var adapterOperations: [BlockOperation] = []
        
        let completionOperation = BlockOperation {
            fetchOperations.forEach { fetchOperation in
                self.feedResults[fetchOperation.feedObjectID]!.fetchError = fetchOperation.error
            }
            
            parseOperations.forEach { parseOperation in
                self.feedResults[parseOperation.feedObjectID]!.parserError = parseOperation.error
                self.feedResults[parseOperation.feedObjectID]!.parsedFeed = parseOperation.parsedFeed
            }
            
            faviconResultOperations.forEach { faviconResultOperation in
                self.feedResults[faviconResultOperation.feedObjectID]!.fetchMeta = true
                self.feedResults[faviconResultOperation.feedObjectID]!.favicon = faviconResultOperation.favicon
            }
            
            self.progress.completedUnitCount += 1
        }
        
        // Initialize empty feed result objects
        refreshable.feedsArray.forEach { feed in
            let fetchMeta = feed.refreshed == nil
            feedResults[feed.objectID] = FeedResult(feedObjectID: feed.objectID)
            
            // Create standard feed operations
            let fetchOperation = FetchOperation(feedObjectID: feed.objectID, url: feed.url!)
            let parseOperation = ParseOperation(feedObjectID: feed.objectID)
            let fetchParseAdapter = BlockOperation() { [unowned parseOperation, unowned fetchOperation] in
                parseOperation.data = fetchOperation.data
            }
            
            fetchParseAdapter.addDependency(fetchOperation)
            parseOperation.addDependency(fetchParseAdapter)
    
            fetchOperations.append(fetchOperation)
            parseOperations.append(parseOperation)
            adapterOperations.append(fetchParseAdapter)
            
            if fetchMeta {
                // Add additional operations for fetching metadata
                let webpageOperation = WebpageOperation()
                let parseWebpageAdapter = BlockOperation() { [unowned webpageOperation, unowned parseOperation] in
                    webpageOperation.webpage = parseOperation.parsedFeed?.webpage
                }
                let metadataOperation = MetadataOperation()
                let webpageMetadataAdapter = BlockOperation() { [unowned metadataOperation, unowned webpageOperation] in
                    metadataOperation.webpage = webpageOperation.webpage
                    metadataOperation.data = webpageOperation.data
                }
                let checkWebpageFaviconOperation = CheckFaviconOperation()
                let checkDefaultFaviconOperation = CheckFaviconOperation()
                let faviconCheckMetadataAdapter = BlockOperation() { [unowned metadataOperation, unowned checkWebpageFaviconOperation, unowned checkDefaultFaviconOperation] in
                    checkWebpageFaviconOperation.checkLocation = metadataOperation.webpageFavicon
                    checkDefaultFaviconOperation.checkLocation = metadataOperation.defaultFavicon
                }
                let faviconCheckStatusAdapter = BlockOperation() {[unowned checkWebpageFaviconOperation, unowned checkDefaultFaviconOperation] in
                    checkDefaultFaviconOperation.performCheck = checkWebpageFaviconOperation.foundFavicon == nil
                }
                let faviconResultOperation = FaviconResultOperation(feedObjectID: feed.objectID)
                let checkFaviconResultAdapterOperation = BlockOperation() { [
                    unowned faviconResultOperation,
                    unowned checkWebpageFaviconOperation,
                    unowned checkDefaultFaviconOperation
                ] in
                    faviconResultOperation.checkedWebpageFavicon = checkWebpageFaviconOperation.foundFavicon
                    faviconResultOperation.checkedDefaultFavicon = checkDefaultFaviconOperation.foundFavicon
                }
                
                parseWebpageAdapter.addDependency(parseOperation)
                webpageOperation.addDependency(parseWebpageAdapter)
                webpageMetadataAdapter.addDependency(webpageOperation)
                metadataOperation.addDependency(webpageMetadataAdapter)
                faviconCheckMetadataAdapter.addDependency(metadataOperation)
                checkWebpageFaviconOperation.addDependency(faviconCheckMetadataAdapter)
                faviconCheckStatusAdapter.addDependency(checkWebpageFaviconOperation)
                checkDefaultFaviconOperation.addDependency(faviconCheckStatusAdapter)
                checkFaviconResultAdapterOperation.addDependency(checkWebpageFaviconOperation)
                checkFaviconResultAdapterOperation.addDependency(checkDefaultFaviconOperation)
                faviconResultOperation.addDependency(checkFaviconResultAdapterOperation)
                
                webpageOperations.append(webpageOperation)
                metadataOperations.append(metadataOperation)
                adapterOperations.append(parseWebpageAdapter)
                adapterOperations.append(webpageMetadataAdapter)
                adapterOperations.append(faviconCheckMetadataAdapter)
                checkFaviconOperations.append(checkWebpageFaviconOperation)
                adapterOperations.append(faviconCheckStatusAdapter)
                checkFaviconOperations.append(checkDefaultFaviconOperation)
                adapterOperations.append(checkFaviconResultAdapterOperation)
                faviconResultOperations.append(faviconResultOperation)
                
                faviconResultOperation.completionBlock = {
                    self.progress.completedUnitCount += 1
                }
                completionOperation.addDependency(faviconResultOperation)
            } else {
                parseOperation.completionBlock = {
                    self.progress.completedUnitCount += 1
                }
                completionOperation.addDependency(parseOperation)
            }
        }
        
        var combinedOperations: [Operation] = []
        combinedOperations.append(contentsOf: fetchOperations)
        combinedOperations.append(contentsOf: parseOperations)
        combinedOperations.append(contentsOf: webpageOperations)
        combinedOperations.append(contentsOf: metadataOperations)
        combinedOperations.append(contentsOf: adapterOperations)
        combinedOperations.append(contentsOf: checkFaviconOperations)
        combinedOperations.append(contentsOf: faviconResultOperations)
        combinedOperations.append(completionOperation)
        
        return combinedOperations
    }
    
    /**
     Atom feed handler responsible for populating application data model from FeedKit AtomFeed result.
     */
    private func updateFeed(feed: Feed, content: AtomFeed, moc managedObjectContext: NSManagedObjectContext) {
        if feed.title == nil {
            if let feedTitle = content.title?.trimmingCharacters(in: .whitespacesAndNewlines) {
                feed.title = feedTitle
            }
        }
        
        if feed.link == nil {
            if
                let atomLink = content.links?.first(where: { atomLink in
                    atomLink.attributes?.rel == "alternate" || atomLink.attributes?.rel == nil
                }),
                let homepageURL = atomLink.attributes?.href
            {
                feed.link = URL(string: homepageURL)
            }
        }
        
        guard let atomEntries = content.entries else {
            // TODO: HANDLE MISSING ATOM ENTRIES
            return
        }
        
        atomEntries.prefix(10).forEach { atomEntry in
            // Continue if link is missing
            guard let itemLink = atomEntry.linkURL else {
                print("MISSING LINK")
                return
            }
            
            // Continue if item already exists
            if (feed.itemsArray.contains(where: { item in item.link == itemLink })) {
                return
            }
            
            let newItem = createItem(atomEntry: atomEntry, moc: managedObjectContext)
            feed.addToItems(newItem)
        }
        
        // Cleanup items not present in feed
        feed.itemsArray.forEach({ item in
            if (
                atomEntries.contains(where: { feedItem in
                    guard let atomEntryAlternateLink = feedItem.linkURL else {
                        return false
                    }
                    
                    return item.link == atomEntryAlternateLink
                }) == false
            ) {
                print("Cleaning up item \(item.title ?? "Untitled")...")
                feed.removeFromItems(item)
            }
        })
    }
    
    /**
     RSS feed handler responsible for populating application data model from FeedKit RSSFeed result.
     */
    private func updateFeed(feed: Feed, content: RSSFeed, moc managedObjectContext: NSManagedObjectContext) {
        if feed.title == nil {
            if let feedTitle = content.title?.trimmingCharacters(in: .whitespacesAndNewlines) {
                feed.title = feedTitle
            }
        }
        
        if feed.link == nil {
            if let homepage = content.link?.trimmingCharacters(in: .whitespacesAndNewlines), let homepageURL = URL(string: homepage) {
                feed.link = homepageURL
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
            if (feed.itemsArray.contains(where: { item in item.link == itemLink})) {
                return
            }
            
            let newItem = createItem(rssItem: rssItem, moc: managedObjectContext)
            feed.addToItems(newItem)
        }
        
        // Cleanup items not present in feed
        feed.itemsArray.forEach({ item in
            if (
                rssItems.contains(where: { (feedItem) -> Bool in
                    guard let feedItemLink = feedItem.linkURL else { return false }
                    return item.link == feedItemLink
                }) == false
            ) {
                feed.removeFromItems(item)
            }
        })
    }
    
    /**
     TODO: JSON Feed importer
     */
    private func updateFeed(feed: Feed, content: JSONFeed, moc managedObjectContext: NSManagedObjectContext) {
        feed.title = content.title
    }
    
    /**
     Creates item entity from an Atom feed entry
     */
    private func createItem(atomEntry: AtomFeedEntry, moc managedObjectContext: NSManagedObjectContext) -> Item {
        let item = Item.init(context: managedObjectContext)
        item.id = UUID()

        if let published = atomEntry.published {
            item.published = published
        } else {
            if let published = atomEntry.updated {
                item.published = published
            }
        }
        
        if let title = atomEntry.title {
            item.title = title.trimmingCharacters(in: .whitespacesAndNewlines).htmlUnescape()
        } else {
            item.title = "Untitled"
        }
        
        item.link = atomEntry.linkURL
        
        // Look for preview image in <links> and <media:content>
        if
            let imageLink = atomEntry.links?.first(where: { link in
                guard
                    link.attributes?.rel == "enclosure",
                    let linkMimeType = link.attributes?.type,
                    let _ = MIMETypes.ImageMIMETypes(rawValue: linkMimeType)
                else {
                    return false
                }
                return true
            }),
            let imageURLString = imageLink.attributes?.href,
            let imageURL = URL(string: imageURLString)
        {
            item.image = imageURL
        } else if
            let media = atomEntry.media,
            let imageMediaContent = media.mediaContents?.first(where: { mediaContent in
                guard
                    let mediaMimeType = mediaContent.attributes?.type,
                    let _ = MIMETypes.ImageMIMETypes(rawValue: mediaMimeType)
                else {
                    return false
                }
                
                return true
            }),
            let mediaURLString = imageMediaContent.attributes?.url,
            let mediaURL = URL(string: mediaURLString)
        {
            item.image = mediaURL
        }
        
        return item
    }
    
    /**
     Creates item entity from a RSS feed item
     */
    private func createItem(rssItem: RSSFeedItem, moc managedObjectContext: NSManagedObjectContext) -> Item {
        let item = Item.init(context: managedObjectContext)
        item.id = UUID()
        
        // Prefer RSS pubDate element for published date
        if let published = rssItem.pubDate {
            item.published = published
        } else {
            // Fallback to Dublin Core metadata for published date (ex. http://feeds.feedburner.com/oatmealfeed does not have pubDate)
            if let published = rssItem.dublinCore?.dcDate {
                item.published = published
            }
        }
        
        if let title = rssItem.title {
            item.title = title.trimmingCharacters(in: .whitespacesAndNewlines).htmlUnescape()
        } else {
            item.title = "Untitled"
        }

        item.link = rssItem.linkURL
        
        // Look for preview image in <enclosure> and <media:content>
        if
            let enclosure = rssItem.enclosure,
            let mimeTypeString = enclosure.attributes?.type,
            let _ = MIMETypes.ImageMIMETypes(rawValue: mimeTypeString),
            let enclosureURLString = enclosure.attributes?.url,
            let enclosureURL = URL(string: enclosureURLString)
        {
            item.image = enclosureURL
        } else if
            let media = rssItem.media,
            let imageMediaContent = media.mediaContents?.first(where: { mediaContent in
                guard
                    let mediaMimeType = mediaContent.attributes?.type,
                    let _ = MIMETypes.ImageMIMETypes(rawValue: mediaMimeType)
                else {
                    return false
                }
                
                return true
            }),
            let mediaURLString = imageMediaContent.attributes?.url,
            let mediaURL = URL(string: mediaURLString)
        {
            item.image = mediaURL
        }
        
        return item
    }
}
