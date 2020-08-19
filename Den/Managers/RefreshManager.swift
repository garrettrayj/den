//
//  RefreshManager.swift
//  Den
//
//  Created by Garrett Johnson on 8/16/20.
//  Copyright © 2020 Garrett Johnson. All rights reserved.
//

import Foundation
import SwiftUI
import CoreData
import FeedKit

class RefreshManager: ObservableObject {
    enum RefreshManagerError: Error {
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
    
    @Published public var refreshing: Bool = false
    @Published public var currentRefreshable: Refreshable?
    
    public var progress = Progress(totalUnitCount: 1)
    
    private var queue = OperationQueue()
    private var feedResults: [NSManagedObjectID: FeedResult] = [:]
    private var operations: [Operation] = []
    private var parentContext: NSManagedObjectContext
    private var privateContext: NSManagedObjectContext

    init(parentContext: NSManagedObjectContext) {
        self.parentContext = parentContext
        
        self.privateContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        privateContext.parent = self.parentContext
        privateContext.undoManager = nil
    }
    
    public func refresh(_ refreshable: Refreshable) {
        if refreshing == false {
            refreshing = true
            currentRefreshable = refreshable
        } else {
            print("Update manager already updating feeds")
            return
        }
        
        // Reset total progress units to number of fetch operations + one unit for completion operation + one unit for CoreData save
        let feedCount = Int64(refreshable.feedsArray.count)
        progress.totalUnitCount = feedCount + 1 + 1
        progress.completedUnitCount = 0
        
        DispatchQueue.global(qos: .userInitiated).async {
            self.operations = self.createOperations(refreshable)
            self.queue.addOperations(self.operations, waitUntilFinished: true)
            
            // Bounce back to the main thread to setup private managed object context
            DispatchQueue.main.async {
                // Perform managed object update in background
                self.privateContext.perform {
                    for (feedObjectID, feedResult) in self.feedResults {
                        autoreleasepool {
                            let feed = self.privateContext.object(with: feedObjectID) as! Feed
                            
                            if feedResult.fetchMeta == true {
                                feed.favicon = feedResult.favicon
                            }
                            feed.refreshed = Date()
                            
                            switch feedResult.parsedFeed  {
                                case let .atom(content):
                                    feed.ingest(content: content, moc: self.privateContext)
                                case let .rss(content):
                                    feed.ingest(content: content, moc: self.privateContext)
                                case let .json(content):
                                    feed.ingest(content: content, moc: self.privateContext)
                                case .none:
                                    print("Fetch failed for \(feed.urlString)")
                            }
                        }
                    }
                    
                    if self.privateContext.hasChanges {
                        do {
                            try self.privateContext.save()
                            print("Successfully saved private context")
                            
                            // Jump back into main thread to save changes merged into parent managed object context (viewContext) and update UI
                            self.parentContext.performAndWait {
                                refreshable.onRefreshComplete()
                                do {
                                    try self.parentContext.save()
                                    print("Successfully saved view context")
                                } catch {
                                    fatalError("Failure to save view context: \(error)")
                                }
                                
                                self.progress.completedUnitCount += 1
                                self.reset()
                            }
                        } catch {
                            fatalError("Failure to save private context: \(error)")
                        }
                    }
                }
            }
        }
    }
    
    public func isRefreshing(_ refreshable: Refreshable) -> Bool {
        refreshable == self.currentRefreshable && self.refreshing == true
    }
    
    private func createOperations(_ refreshable: Refreshable) -> [Operation] {
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
    
    private func reset() {
        self.feedResults = [:]
        self.operations = []
        self.privateContext.reset()
        self.currentRefreshable = nil
        self.refreshing = false
        
        URLSession.shared.flush {
            // Flushed URL session
        }
    }
}
