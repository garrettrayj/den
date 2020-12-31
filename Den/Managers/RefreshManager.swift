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
    @Published public var refreshing: Bool = false
    @Published public var refreshingFeeds: [Feed] = []
    
    public var progress = Progress(totalUnitCount: 0)
    private var queue = OperationQueue()
    private var persistentContainer: NSPersistentContainer

    init(persistentContainer: NSPersistentContainer) {
        self.persistentContainer = persistentContainer
    }
    
    public func refresh(_ page: Page) {
        page.feedsArray.forEach { feed in
            self.refresh(feed)
        }
    }
    
    public func refresh(_ feed: Feed) {
        // Skip if feed is already queued for refresh
        if refreshingFeeds.contains(feed) {
            return
        }
        
        refreshingFeeds.append(feed)
        progress.totalUnitCount += 1
        
        DispatchQueue.global(qos: .userInitiated).async {
            self.queue.addOperations(self.createFeedOperations(feed: feed), waitUntilFinished: false)
        }
    }
    
    public func feedIsRefreshing(feed: Feed) -> Bool {
        refreshingFeeds.contains(feed)
    }
    
    public func pageIsRefreshing(page: Page) -> Bool {
        refreshingFeeds.contains { feed in
            feed.page == page
        }
    }
    
    private func createFeedOperations(feed: Feed) -> [Operation] {
        guard let feedURL = feed.url else {
            return []
        }
        
        var operations: [Operation] = []
        let fetchMeta = feed.refreshed == nil
                
        // Create standard feed operations
        let fetchOperation = FetchOperation(url: feedURL)
        let parseOperation = ParseOperation()
        let ingestOperation = IngestOperation(persistentContainer: persistentContainer, feedObjectID: feed.objectID)
        
        let fetchParseAdapter = BlockOperation() { [unowned parseOperation, unowned fetchOperation] in
            parseOperation.data = fetchOperation.data
        }
        
        let deduplicationOperation = DeduplicationOperation(persistentContainer: persistentContainer, feedObjectID: feed.objectID)
        
        let completionOperation = BlockOperation {
            DispatchQueue.main.async {
                self.progress.completedUnitCount += 1
                if self.progress.fractionCompleted == 1 {
                    self.refreshing = false
                }
                self.refreshingFeeds.removeAll { refreshingFeed in
                    refreshingFeed == feed
                }
                
                feed.page?.objectWillChange.send()
            }
        }
        
        fetchParseAdapter.addDependency(fetchOperation)
        parseOperation.addDependency(fetchParseAdapter)
        deduplicationOperation.addDependency(ingestOperation)
        completionOperation.addDependency(deduplicationOperation)

        operations.append(fetchOperation)
        operations.append(parseOperation)
        operations.append(ingestOperation)
        operations.append(fetchParseAdapter)
        operations.append(deduplicationOperation)
        operations.append(completionOperation)

        if !fetchMeta {
            // Regular feed update without fetching meta
            let ingestAdapter = BlockOperation() { [unowned fetchOperation, unowned parseOperation, unowned ingestOperation] in
                ingestOperation.httpResponse = fetchOperation.response
                ingestOperation.transportError = fetchOperation.error
                ingestOperation.parsedFeed = parseOperation.parsedFeed
                ingestOperation.parserError = parseOperation.error
            }
            
            ingestAdapter.addDependency(parseOperation)
            ingestOperation.addDependency(ingestAdapter)
            
            operations.append(ingestAdapter)
        } else {
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
            
            // Create ingest adapter that also passes favicon results
            let ingestAdapter = BlockOperation() { [
                unowned fetchOperation,
                unowned parseOperation,
                unowned ingestOperation,
                unowned faviconResultOperation
            ] in
                ingestOperation.httpResponse = fetchOperation.response
                ingestOperation.transportError = fetchOperation.error
                ingestOperation.parsedFeed = parseOperation.parsedFeed
                ingestOperation.parserError = parseOperation.error
                ingestOperation.fetchMeta = true
                ingestOperation.favicon = faviconResultOperation.favicon
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
            ingestAdapter.addDependency(faviconResultOperation)
            ingestOperation.addDependency(ingestAdapter)
            
            operations.append(webpageOperation)
            operations.append(metadataOperation)
            operations.append(parseWebpageAdapter)
            operations.append(webpageMetadataAdapter)
            operations.append(faviconCheckMetadataAdapter)
            operations.append(checkWebpageFaviconOperation)
            operations.append(faviconCheckStatusAdapter)
            operations.append(checkDefaultFaviconOperation)
            operations.append(checkFaviconResultAdapterOperation)
            operations.append(faviconResultOperation)
            operations.append(ingestAdapter)
        }
        
        return operations
    }
    
    private func reset() {
        progress.completedUnitCount = 0
        refreshing = false
        refreshingFeeds = []
    }
}
