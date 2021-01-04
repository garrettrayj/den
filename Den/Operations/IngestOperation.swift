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

class IngestOperation: Operation {
    var transportError: Error?
    var httpResponse: HTTPURLResponse?
    var parserError: FeedKit.ParserError?
    var parsedFeed: FeedKit.Feed?
    var fetchMeta: Bool = false
    var favicon: URL?
    var feedObjectID: NSManagedObjectID
    
    private var persistentContainer: NSPersistentContainer
    private var crashManager: CrashManager
    
    init(persistentContainer: NSPersistentContainer, feedObjectID: NSManagedObjectID, crashManager: CrashManager) {
        self.persistentContainer = persistentContainer
        self.feedObjectID = feedObjectID
        self.crashManager = crashManager
        super.init()
    }

    override func main() {
        let context: NSManagedObjectContext = self.persistentContainer.newBackgroundContext()
        context.undoManager = nil
        context.performAndWait {
            let feed = context.object(with: feedObjectID) as! Feed
            ingestFeed(context: context, feed: feed)
            deduplicateFeedItems(context: context, feed: feed)
            
            if context.hasChanges {
                do {
                    try context.save()
                } catch {
                    DispatchQueue.main.async {
                        self.crashManager.handleCriticalError(error as NSError)
                    }
                }
            }
        }
    }
    
    func ingestFeed(context: NSManagedObjectContext, feed: Feed) {
        if let transportError = transportError {
            feed.error = transportError.localizedDescription
            Logger.ingest.notice("Transport error while fetching \"\(feed.wrappedTitle)\" (\(feed.urlString)): \(feed.error!)")
            return
        }
        
        guard let httpResponse = httpResponse else {
            feed.error = "Server did not respond"
            Logger.ingest.notice("Server did not respond to request for \"\(feed.wrappedTitle)\" (\(feed.urlString)): \(feed.error!)")
            return
        }
        
        feed.httpStatus = Int16(httpResponse.statusCode)
        
        if !(200...299).contains(httpResponse.statusCode) {
            feed.error = HTTPURLResponse.localizedString(forStatusCode: httpResponse.statusCode).capitalized(with: .autoupdatingCurrent)
            Logger.ingest.notice("Invalid HTTP response from \"\(feed.wrappedTitle)\" (\(feed.urlString)): \(feed.error!)")
            return
        }
        
        if let parserError = parserError {
            feed.error = "Failed to parse feed content"
            Logger.ingest.notice("Failed to parse response from \"\(feed.wrappedTitle)\" (\(feed.urlString)): \(parserError.localizedDescription)")
            return
        }
        
        switch parsedFeed  {
            case let .atom(content):
                if content.entries == nil || content.entries?.count == 0 {
                    feed.error = "Feed empty"
                    Logger.ingest.notice("Atom feed has no items \"\(feed.wrappedTitle)\" (\(feed.urlString)): \(feed.error!)")
                    return
                }
                feed.ingest(content: content, moc: context)
            case let .rss(content):
                if content.items == nil || content.items?.count == 0 {
                    feed.error = "Feed empty"
                    Logger.ingest.notice("RSS feed has no items \"\(feed.wrappedTitle)\" (\(feed.urlString)): \(feed.error!)")
                    return
                }
                feed.ingest(content: content, moc: context)
            case let .json(content):
                if content.items == nil || content.items?.count == 0 {
                    feed.error = "Feed empty"
                    Logger.ingest.notice("JSON feed has no items \"\(feed.wrappedTitle)\" (\(feed.urlString)): \(feed.error!)")
                    return
                }
                feed.ingest(content: content, moc: context)
            case .none:
                feed.error = "Unknown feed format"
                Logger.ingest.notice("Unknown feed format for \"\(feed.wrappedTitle)\" (\(feed.urlString)): \(feed.error!)")
                return
        }
        
        if fetchMeta == true {
            feed.favicon = favicon
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
