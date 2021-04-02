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

class RefreshManager: ObservableObject {
    @Published public var refreshing: Bool = false
    
    public var progress = Progress(totalUnitCount: 0)
    
    private var queue = OperationQueue()
    private var persistentContainer: NSPersistentContainer
    private var crashManager: CrashManager
    
    init(persistenceManager: PersistenceManager, crashManager: CrashManager) {
        self.persistentContainer = persistenceManager.container
        self.crashManager = crashManager
    }
    
    public func refresh(_ page: Page) {
        page.subscriptionsArray.forEach { subscription in
            self.refresh(subscription)
        }
    }
    
    public func refresh(_ subscription: Subscription) {
        refreshing = true
        progress.totalUnitCount += 1
        
        let fetchMeta = false // TODO:
        
        
        DispatchQueue.global(qos: .userInitiated).async {
            self.queue.addOperations(
                self.createFeedOperations(subscription: subscription, fetchMeta: fetchMeta),
                waitUntilFinished: false
            )
        }
    }
    
    private func createFeedOperations(subscription: Subscription, fetchMeta: Bool) -> [Operation] {
        var operations: [Operation] = []
        
        guard let feedURL = subscription.url else {
            return []
        }
         
        // Create standard feed operations
        let fetchOperation = FetchOperation(url: feedURL)
        let parseOperation = ParseOperation()
        let ingestOperation = IngestOperation(
            persistentContainer: persistentContainer,
            subscriptionObjectID: subscription.objectID
        )
        
        let fetchParseAdapter = BlockOperation() { [unowned parseOperation, unowned fetchOperation] in
            parseOperation.data = fetchOperation.data
        }
        
        let completionOperation = BlockOperation {
            DispatchQueue.main.async {
                self.progress.completedUnitCount += 1
                if self.progress.isFinished {
                    self.refreshing = false
                    subscription.page?.objectWillChange.send()
                }
            }
        }
        
        fetchParseAdapter.addDependency(fetchOperation)
        parseOperation.addDependency(fetchParseAdapter)
        completionOperation.addDependency(ingestOperation)

        operations.append(fetchOperation)
        operations.append(parseOperation)
        operations.append(ingestOperation)
        operations.append(fetchParseAdapter)
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
            let faviconResultOperation = FaviconResultOperation()
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
}
