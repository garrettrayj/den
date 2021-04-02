//
//  IngestOperation.swift
//  Den
//
//  Created by Garrett Johnson on 8/26/20.
//  Copyright © 2020 Garrett Johnson. All rights reserved.
//

import Foundation
import CoreData
import FeedKit
import OSLog
import UIKit
import URLImage
import Combine
import func AVFoundation.AVMakeRect

class IngestOperation: AsynchronousOperation {
    var transportError: Error?
    var httpResponse: HTTPURLResponse?
    var parserError: FeedKit.ParserError?
    var parsedFeed: FeedKit.Feed?
    var fetchMeta: Bool = false
    var favicon: URL?
    var subscriptionObjectID: NSManagedObjectID
    var feedIngestMeta: Feed.FeedIngestMeta?
    
    private var persistentContainer: NSPersistentContainer
    private var cancellable: AnyCancellable?
    
    init(persistentContainer: NSPersistentContainer, subscriptionObjectID: NSManagedObjectID) {
        self.persistentContainer = persistentContainer
        self.subscriptionObjectID = subscriptionObjectID
        super.init()
    }
    
    override func cancel() {
        cancellable?.cancel()
        super.cancel()
    }

    override func main() {
        let context: NSManagedObjectContext = self.persistentContainer.newBackgroundContext()
        context.undoManager = nil
        context.performAndWait {
            let subscription = context.object(with: subscriptionObjectID) as! Subscription
            let feed: Feed = (subscription.feed != nil) ? subscription.feed! : Feed.create(in: context, subscriptionId: subscription.id!)
            
            ingestFeed(context: context, subscription: subscription, feed: feed)
            deduplicateFeedItems(context: context, feed: feed)
            feed.refreshed = Date()
            
            // Cache thumbnail images (this is the async part of operation)
            if let thumbnails = feedIngestMeta?.thumbnails, thumbnails.count > 0 {
                let publishers = thumbnails.map { URLImageService.shared.remoteImagePublisher($0) }
                cancellable = Publishers.MergeMany(publishers)
                    .tryMap { $0.cgImage }
                    .catch { _ in
                        Just(nil)
                    }
                    .collect()
                    .sink { images in
                        // images is [CGImage?]
                        self.saveContext(context: context)
                        self.finish()
                    }
            } else {
                self.saveContext(context: context)
                self.finish()
            }
        }
    }
    
    func saveContext(context: NSManagedObjectContext) {
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                DispatchQueue.main.async {
                    CrashManager.shared.handleCriticalError(error as NSError)
                }
            }
        }
    }
    
    func ingestFeed(context: NSManagedObjectContext, subscription: Subscription, feed: Feed) {
        if let transportError = transportError {
            feed.error = transportError.localizedDescription
            Logger.ingest.notice("Transport error while fetching \"\(subscription.wrappedTitle)\" (\(subscription.urlString)): \(feed.error!)")
            return
        }
        
        guard let httpResponse = httpResponse else {
            feed.error = "Server did not respond"
            Logger.ingest.notice("Server did not respond to request for \"\(subscription.wrappedTitle)\" (\(subscription.urlString)): \(feed.error!)")
            return
        }
        
        feed.httpStatus = Int16(httpResponse.statusCode)
        
        if !(200...299).contains(feed.httpStatus) {
            feed.error = HTTPURLResponse.localizedString(forStatusCode: httpResponse.statusCode).capitalized(with: .autoupdatingCurrent)
            Logger.ingest.notice("Invalid HTTP response from \"\(subscription.wrappedTitle)\" (\(subscription.urlString)): \(feed.error!)")
            return
        }
        
        if let parserError = parserError {
            feed.error = "Failed to parse feed content"
            Logger.ingest.notice("Failed to parse response from \"\(subscription.wrappedTitle)\" (\(subscription.urlString)): \(parserError.localizedDescription)")
            return
        }
        
        switch parsedFeed  {
            case let .atom(content):
                if content.entries == nil || content.entries?.count == 0 {
                    feed.error = "Feed empty"
                    Logger.ingest.notice("Atom feed has no items \"\(subscription.wrappedTitle)\" (\(subscription.urlString)): \(feed.error!)")
                    return
                }
                
                feedIngestMeta = feed.ingest(content: content, moc: context)

            case let .rss(content):
                if content.items == nil || content.items?.count == 0 {
                    feed.error = "Feed empty"
                    Logger.ingest.notice("RSS feed has no items \"\(subscription.wrappedTitle)\" (\(subscription.urlString)): \(feed.error!)")
                    return
                }
                
                feedIngestMeta = feed.ingest(content: content, moc: context)
                
            case let .json(content):
                if content.items == nil || content.items?.count == 0 {
                    feed.error = "Feed empty"
                    Logger.ingest.notice("JSON feed has no items \"\(subscription.wrappedTitle)\" (\(subscription.urlString)): \(feed.error!)")
                    return
                }
                feedIngestMeta = feed.ingest(content: content, moc: context)
            case .none:
                feed.error = "Unknown feed format"
                Logger.ingest.notice("Unknown feed format for \"\(subscription.wrappedTitle)\" (\(subscription.urlString)): \(feed.error!)")
                return
        }
        
        if fetchMeta == true {
            feed.favicon = favicon
            feed.metaFetched = Date()
        }
        
        feed.error = nil
    }
    
    func deduplicateFeedItems(context: NSManagedObjectContext, feed: Feed) {
        let crossReference = Dictionary(grouping: feed.itemsArray, by: { $0.link })
        let duplicates = crossReference
            .filter { $1.count > 1 }             // filter down to only those with multiple contacts
            .sorted { $0.1.count > $1.1.count }  // sort in descending order by number of duplicates
        
        duplicates.forEach { (link, item) in
            let duplicateGroup = feed.itemsArray.filter { item in
                item.link == link
            }
            
            duplicateGroup.suffix(from: 1).forEach { item in
                context.delete(item)
                feed.removeFromItems(item)
            }
        }
    }
}
