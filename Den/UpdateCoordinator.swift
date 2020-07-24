//
//  FeedUpdater.swift
//  Den
//
//  Created by Garrett Johnson on 7/4/20.
//  Copyright © 2020 Garrett Johnson. All rights reserved.
//

import Foundation
import SwiftUI
import CoreData

class UpdateCoordinator: ObservableObject {
    @Published var refreshing: Bool = false

    var queue = OperationQueue()
    
    func refresh(refreshable: Refreshable) {
        refreshing = true
        
        DispatchQueue.global(qos: .userInteractive).async {
            refreshable.feedArray.forEach { feed in
                self.queueUpdate(feed: feed)
            }
            self.queue.waitUntilAllOperationsAreFinished()
            
            DispatchQueue.main.sync {
                self.refreshing = false
            }
        }
    }
    
    func queueUpdate(feed: Feed) {
        let fetchFeedOperation = FetchFeedOperation(session: URLSession.shared, url: feed.url!)
        let parseFeedOperation = ParseFeedOperation(feed: feed)
        /// Create adapter for passing data from producer (fetch) to consumer (parse)
        let feedDataAdapter = BlockOperation() { [unowned parseFeedOperation, unowned fetchFeedOperation] in
            parseFeedOperation.feedData = fetchFeedOperation.feedData
        }

        feedDataAdapter.addDependency(fetchFeedOperation)
        parseFeedOperation.addDependency(feedDataAdapter)
        var updateOperations: Array<Operation> = [fetchFeedOperation, feedDataAdapter, parseFeedOperation]
        
        /// Append additional operations for new feeds
        if feed.favicon == nil {
            let fetchHomepageOperation = FetchHomepageOperation(feed: feed)
            let parseMetadataOperation = ParseMetadataOperation(feed: feed)
            let homepageDataAdapter = BlockOperation() { [unowned parseMetadataOperation, unowned fetchHomepageOperation] in
                parseMetadataOperation.homepageData = fetchHomepageOperation.homepageData
            }
            
            fetchHomepageOperation.addDependency(parseFeedOperation)
            homepageDataAdapter.addDependency(fetchHomepageOperation)
            parseMetadataOperation.addDependency(homepageDataAdapter)
            updateOperations.append(fetchHomepageOperation)
            updateOperations.append(homepageDataAdapter)
            updateOperations.append(parseMetadataOperation)
        }
        
        // Add the set of feed update operation to queue
        queue.addOperations(updateOperations, waitUntilFinished: false)
    }
}
