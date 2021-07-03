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
import OSLog

final class RefreshManager: ObservableObject {
    @Published public var refreshing: Bool = false
    
    public var progress = Progress(totalUnitCount: 0)
    
    private var queue = OperationQueue()
    private var persistentContainer: NSPersistentContainer
    private var crashManager: CrashManager
    
    init(persistentContainer: NSPersistentContainer, crashManager: CrashManager) {
        self.persistentContainer = persistentContainer
        self.crashManager = crashManager
    }
    
    public func refresh(_ page: Page) {
        page.feedsArray.forEach { feed in
            self.refresh(feed)
        }
    }
    
    public func refresh(_ feed: Feed) {
        refreshing = true
        progress.totalUnitCount += 1
        
        let feedData = self.checkFeedData(feed)
        
        var operations: [Operation] = []
        
        // Fetch meta (favicon, etc.) on first refresh or if user cleared cache, then check for updates occasionally
        if feedData.metaFetched == nil || feedData.metaFetched! < Date(timeIntervalSinceNow: -7 * 24 * 60 * 60) {
            operations = self.planFullUpdate(feed: feed, feedData: feedData)
        } else {
            operations = self.planContentUpdate(feed: feed, feedData: feedData)
        }
        
        DispatchQueue.global(qos: .userInitiated).async {
            self.queue.addOperations(operations, waitUntilFinished: false)
        }
    }
    
    private func checkFeedData(_ feed: Feed) -> FeedData {
        if feed.feedData == nil {
            let feed = FeedData.create(in: self.persistentContainer.viewContext, feedId: feed.id!)
            do {
                try self.persistentContainer.viewContext.save()
            } catch {
                DispatchQueue.main.async {
                    self.crashManager.handleCriticalError(error as NSError)
                }
            }
            
            return feed
        }
        
        return feed.feedData!
    }
    
    private func planFullUpdate(feed: Feed, feedData: FeedData) -> [Operation] {
        var operations: [Operation] = []
        
        guard
            let feedUrl = feed.url,
            let itemLimit = feed.page?.wrappedItemsPerFeed
        else {
            return []
        }
        
        let existingItemLinks = feedData.itemsArray.map({ item in
            return item.link!
        })
        
        // Create base operations
        let fetchOperation = DataTaskOperation(feedUrl)
        let parseOperation = ParseFeedData(
            feedUrl: feedUrl,
            itemLimit: itemLimit,
            existingItemLinks: existingItemLinks,
            feedId: feed.id!
        )
        let webpageDataOperation = DataTaskOperation()
        let metadataOperation = MetadataOperation()
        let defaultFaviconDataOperation = DataTaskOperation()
        let webpageFaviconDataOperation = DataTaskOperation()
        let saveFaviconOperation = SaveFaviconOperation()
        let downloadThumbnailsOperation = DownloadThumbnailsOperation()
        let saveFeedOperation = SaveFeedOperation(
            persistentContainer: self.persistentContainer,
            crashManager: self.crashManager,
            feedObjectID: feed.objectID,
            saveMeta: true
        )
        
        let completionOperation = BlockOperation {
            DispatchQueue.main.async {
                self.progress.completedUnitCount += 1
                if self.progress.isFinished {
                    self.refreshFinished(page: feed.page)
                }
            }
        }
        
        // Create adapters
        let fetchParseAdapter = BlockOperation() { [unowned fetchOperation, unowned parseOperation] in
            parseOperation.httpResponse = fetchOperation.response
            parseOperation.httpTransportError = fetchOperation.error
            parseOperation.data = fetchOperation.data
        }

        let parseWebpageAdapter = BlockOperation() { [unowned parseOperation, unowned webpageDataOperation] in
            webpageDataOperation.url = parseOperation.workingFeed.link
        }
        
        let webpageMetadataAdapter = BlockOperation() { [unowned metadataOperation, unowned webpageDataOperation] in
            metadataOperation.webpageUrl = webpageDataOperation.url
            metadataOperation.webpageData = webpageDataOperation.data
        }
        
        let metadataDefaultFaviconDataAdapter = BlockOperation() { [unowned metadataOperation, unowned defaultFaviconDataOperation] in
            defaultFaviconDataOperation.url = metadataOperation.defaultFavicon
        }
        
        let metadataWebpageFaviconDataAdapter = BlockOperation() { [unowned metadataOperation, unowned webpageFaviconDataOperation] in
            webpageFaviconDataOperation.url = metadataOperation.webpageFavicon
        }
        
        let saveFaviconAdapter = BlockOperation() {[
            unowned defaultFaviconDataOperation,
            unowned webpageFaviconDataOperation,
            unowned saveFaviconOperation
        ] in
            saveFaviconOperation.workingFeed = parseOperation.workingFeed
            saveFaviconOperation.defaultFaviconData = defaultFaviconDataOperation.data
            saveFaviconOperation.defaultFaviconResponse = defaultFaviconDataOperation.response
            saveFaviconOperation.webpageFaviconData = webpageFaviconDataOperation.data
            saveFaviconOperation.webpageFaviconResponse = webpageFaviconDataOperation.response
        }
        
        let parseDownloadThumbnailsAdapter = BlockOperation() { [unowned parseOperation, unowned downloadThumbnailsOperation] in
            downloadThumbnailsOperation.inputWorkingItems = parseOperation.workingItems
        }
        
        let saveFeedAdapter = BlockOperation() { [unowned saveFeedOperation, unowned saveFaviconOperation, unowned downloadThumbnailsOperation] in
            saveFeedOperation.workingFeed = saveFaviconOperation.workingFeed
            saveFeedOperation.workingFeedItems = downloadThumbnailsOperation.outputWorkingItems
        }

        // Dependency graph
        fetchParseAdapter.addDependency(fetchOperation)
        parseOperation.addDependency(fetchParseAdapter)
        parseWebpageAdapter.addDependency(parseOperation)
        webpageDataOperation.addDependency(parseWebpageAdapter)
        webpageMetadataAdapter.addDependency(webpageDataOperation)
        metadataOperation.addDependency(webpageMetadataAdapter)
        metadataDefaultFaviconDataAdapter.addDependency(metadataOperation)
        metadataWebpageFaviconDataAdapter.addDependency(metadataOperation)
        defaultFaviconDataOperation.addDependency(metadataDefaultFaviconDataAdapter)
        webpageFaviconDataOperation.addDependency(metadataWebpageFaviconDataAdapter)
        saveFaviconAdapter.addDependency(defaultFaviconDataOperation)
        saveFaviconAdapter.addDependency(webpageFaviconDataOperation)
        saveFaviconOperation.addDependency(saveFaviconAdapter)
        parseDownloadThumbnailsAdapter.addDependency(parseOperation)
        downloadThumbnailsOperation.addDependency(parseDownloadThumbnailsAdapter)
        saveFeedAdapter.addDependency(downloadThumbnailsOperation)
        saveFeedAdapter.addDependency(saveFaviconOperation)
        saveFeedOperation.addDependency(saveFeedAdapter)
        completionOperation.addDependency(saveFeedOperation)

        operations.append(fetchOperation)
        operations.append(fetchParseAdapter)
        operations.append(parseOperation)
        operations.append(parseWebpageAdapter)
        operations.append(webpageDataOperation)
        operations.append(webpageMetadataAdapter)
        operations.append(metadataOperation)
        operations.append(metadataDefaultFaviconDataAdapter)
        operations.append(defaultFaviconDataOperation)
        operations.append(metadataWebpageFaviconDataAdapter)
        operations.append(webpageFaviconDataOperation)
        operations.append(saveFaviconAdapter)
        operations.append(saveFaviconOperation)
        operations.append(parseDownloadThumbnailsAdapter)
        operations.append(downloadThumbnailsOperation)
        operations.append(saveFeedAdapter)
        operations.append(saveFeedOperation)
        operations.append(completionOperation)
        
        return operations
    }
    
    private func planContentUpdate(feed: Feed, feedData: FeedData) -> [Operation] {
        var operations: [Operation] = []
        
        guard
            let feedUrl = feed.url,
            let itemLimit = feed.page?.wrappedItemsPerFeed
        else {
            return []
        }
        
        let existingItemLinks = feedData.itemsArray.map({ item in
            return item.link!
        })
        
        // Create base operations
        let fetchOperation = DataTaskOperation(feedUrl)
        let parseOperation = ParseFeedData(
            feedUrl: feedUrl,
            itemLimit: itemLimit,
            existingItemLinks: existingItemLinks,
            feedId: feedData.id!
        )
        let downloadThumbnailsOperation = DownloadThumbnailsOperation()
        let saveFeedOperation = SaveFeedOperation(
            persistentContainer: self.persistentContainer,
            crashManager: self.crashManager,
            feedObjectID: feed.objectID,
            saveMeta: false
        )
        
        let completionOperation = BlockOperation {
            DispatchQueue.main.async {
                self.progress.completedUnitCount += 1
                if self.progress.isFinished {
                    self.refreshFinished(page: feed.page)
                }
            }
        }
        
        // Create adapters
        let fetchParseAdapter = BlockOperation() { [unowned fetchOperation, unowned parseOperation] in
            parseOperation.httpResponse = fetchOperation.response
            parseOperation.httpTransportError = fetchOperation.error
            parseOperation.data = fetchOperation.data
        }
        
        let parseDownloadThumbnailsAdapter = BlockOperation() { [unowned parseOperation, unowned downloadThumbnailsOperation] in
            downloadThumbnailsOperation.inputWorkingItems = parseOperation.workingItems
        }
        
        let saveFeedAdapter = BlockOperation() { [unowned saveFeedOperation, unowned parseOperation, unowned downloadThumbnailsOperation] in
            saveFeedOperation.workingFeed = parseOperation.workingFeed
            saveFeedOperation.workingFeedItems = downloadThumbnailsOperation.outputWorkingItems
        }

        // Dependency graph
        fetchParseAdapter.addDependency(fetchOperation)
        parseOperation.addDependency(fetchParseAdapter)
        parseDownloadThumbnailsAdapter.addDependency(parseOperation)
        downloadThumbnailsOperation.addDependency(parseDownloadThumbnailsAdapter)
        saveFeedAdapter.addDependency(downloadThumbnailsOperation)
        saveFeedAdapter.addDependency(parseOperation)
        saveFeedOperation.addDependency(saveFeedAdapter)
        completionOperation.addDependency(saveFeedOperation)

        operations.append(fetchOperation)
        operations.append(fetchParseAdapter)
        operations.append(parseOperation)
        operations.append(parseDownloadThumbnailsAdapter)
        operations.append(downloadThumbnailsOperation)
        operations.append(saveFeedAdapter)
        operations.append(saveFeedOperation)
        operations.append(completionOperation)
        
        return operations
    }
    
    private func refreshFinished(page: Page?) {
        if self.persistentContainer.viewContext.hasChanges {
            do {
                try self.persistentContainer.viewContext.save()
            } catch let error as NSError {
                self.crashManager.handleCriticalError(error)
            }
        }
        
        page?.objectWillChange.send()
        
        self.refreshing = false
    }
}
