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
    
    init(persistentContainer: NSPersistentContainer, feedObjectID: NSManagedObjectID) {
        self.persistentContainer = persistentContainer
        self.feedObjectID = feedObjectID
        super.init()
    }

    override func main() {
        let context: NSManagedObjectContext = self.persistentContainer.newBackgroundContext()
        context.undoManager = nil
        
        context.performAndWait {
            ingestFeed(context: context)
            
            if context.hasChanges {
                do {
                    try context.save()
                } catch {
                    fatalError("Unable to save background context: \(error)")
                }
            }
        }
    }
    
    func ingestFeed(context: NSManagedObjectContext) {
        let feed = context.object(with: feedObjectID) as! Feed
        
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
        
        feed.refreshed = Date()
        feed.error = nil
    }
}
