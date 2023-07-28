//
//  FeedUpdateTask.swift
//  Den
//
//  Created by Garrett Johnson on 10/30/22.
//  Copyright © 2022 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import CoreData
import OSLog

import FeedKit

class FeedUpdateTask {
    let feedObjectID: NSManagedObjectID
    let pageObjectID: NSManagedObjectID?
    let profileObjectID: NSManagedObjectID?
    let url: URL
    let updateMeta: Bool
    let timeout: TimeInterval
    
    private var parsedSuccessfully: Bool = false
    private var parserResult: Result<FeedKit.Feed, FeedKit.ParserError>?
    private var start: Double?
    private var webpage: URL?
    
    init(
        feedObjectID: NSManagedObjectID,
        pageObjectID: NSManagedObjectID?,
        profileObjectID: NSManagedObjectID?,
        url: URL,
        updateMeta: Bool,
        timeout: TimeInterval
    ) {
        self.feedObjectID = feedObjectID
        self.pageObjectID = pageObjectID
        self.profileObjectID = profileObjectID
        self.url = url
        self.updateMeta = updateMeta
        self.timeout = timeout
    }

    // swiftlint:disable cyclomatic_complexity function_body_length
    func execute() async {
        start = CFAbsoluteTimeGetCurrent()
        
        let context = PersistenceController.shared.container.newBackgroundContext()
        context.mergePolicy = NSMergePolicy(merge: .mergeByPropertyStoreTrumpMergePolicyType)
        
        let feedRequest = URLRequest(url: url, timeoutInterval: timeout)

        var feedResponse = FeedURLResponse()
        if let (data, urlResponse) = try? await URLSession.shared.data(for: feedRequest) {
            feedResponse.responseTime = Float(CFAbsoluteTimeGetCurrent() - start!)
            if let httpResponse = urlResponse as? HTTPURLResponse {
                feedResponse.statusCode = Int16(httpResponse.statusCode)
                feedResponse.server = httpResponse.value(forHTTPHeaderField: "Server")
                feedResponse.cacheControl = httpResponse.value(forHTTPHeaderField: "Cache-Control")
                feedResponse.age = httpResponse.value(forHTTPHeaderField: "Age")
                feedResponse.eTag = httpResponse.value(forHTTPHeaderField: "ETag")
            }
            parserResult = FeedParser(data: data).parse()
        }

        await context.perform {
            guard
                let feed = context.object(with: self.feedObjectID) as? Feed,
                let feedId = feed.id
            else { return }

            let feedData = feed.feedData ?? FeedData.create(in: context, feedId: feedId)
            feedData.refreshed = .now
            feedData.responseTime = feedResponse.responseTime
            feedData.httpStatus = feedResponse.statusCode
            feedData.server = feedResponse.server
            feedData.cacheControl = feedResponse.cacheControl
            feedData.age = feedResponse.age
            feedData.eTag = feedResponse.eTag

            self.updateFeed(
                feed: feed,
                feedData: feedData,
                parserResult: self.parserResult,
                context: context
            )

            // Cleanup old items
            let maxItems = feed.extendedItemLimit
            if feedData.itemsArray.count > maxItems {
                feedData.itemsArray.suffix(from: maxItems).forEach { item in
                    feedData.removeFromItems(item)
                    context.delete(item)
                }
            }

            // Update read and extra status of items
            for (idx, item) in feedData.itemsArray.enumerated() {
                item.read = !item.history.isEmpty

                if idx + 1 > feed.wrappedItemLimit {
                    item.extra = true
                } else {
                    item.extra = false
                }
            }

            if !self.updateMeta || !self.parsedSuccessfully {
                self.save(context: context, feed: feed)
            }
        }
        
        if updateMeta && parsedSuccessfully {
            var webpageMetadata: WebpageMetadata.Results?
            if let webpage = webpage {
                let webpageRequest = URLRequest(url: webpage, timeoutInterval: timeout)
                if let (webpageData, _) = try? await URLSession.shared.data(for: webpageRequest) {
                    webpageMetadata = WebpageMetadata(webpage: webpage, data: webpageData).results
                }
            }
            
            await context.perform {
                guard
                    let feed = context.object(with: self.feedObjectID) as? Feed,
                    let feedData = feed.feedData
                else { return }
                
                self.updateFeedMeta(
                    feed: feed,
                    feedData: feedData,
                    parserResult: self.parserResult!,
                    context: context,
                    metadata: webpageMetadata
                )
                
                self.save(context: context, feed: feed)
            }
        }

        DispatchQueue.main.async {
            NotificationCenter.default.post(
                name: .feedRefreshed,
                object: self.profileObjectID,
                userInfo: [
                    "pageObjectID": self.pageObjectID as Any,
                    "feedObjectID": self.feedObjectID as Any
                ]
            )
        }
    }
    
    private func updateFeed(
        feed: Feed,
        feedData: FeedData,
        parserResult: Result<FeedKit.Feed, FeedKit.ParserError>?,
        context: NSManagedObjectContext
    ) {
        switch parserResult {
        case .success(let parsedFeed):
            self.parsedSuccessfully = true
            self.webpage = parsedFeed.webpage
            
            feedData.error = nil

            switch parsedFeed {
            case let .atom(parsedFeed):
                feedData.format = "Atom"
                
                let updater = AtomFeedUpdate(
                    feed: feed,
                    feedData: feedData,
                    source: parsedFeed,
                    context: context
                )
                updater.execute()
            case let .rss(parsedFeed):
                feedData.format = "RSS"
                
                let updater = RSSFeedUpdate(
                    feed: feed,
                    feedData: feedData,
                    source: parsedFeed,
                    context: context
                )
                updater.execute()
            case let .json(parsedFeed):
                feedData.format = "JSON"
                
                let updater = JSONFeedUpdate(
                    feed: feed,
                    feedData: feedData,
                    source: parsedFeed,
                    context: context
                )
                updater.execute()
            }
        case .failure:
            feedData.error = RefreshError.parsing.rawValue
            return
        case .none:
            feedData.error = RefreshError.request.rawValue
        }
    }

    private func updateFeedMeta(
        feed: Feed,
        feedData: FeedData,
        parserResult: Result<FeedKit.Feed, FeedKit.ParserError>,
        context: NSManagedObjectContext,
        metadata: WebpageMetadata.Results? = nil
    ) {
        switch parserResult {
        case .success(let parsedFeed):
            switch parsedFeed {
            case let .atom(parsedFeed):
                let updater = AtomFeedMetaUpdate(
                    feed: feed,
                    feedData: feedData,
                    source: parsedFeed,
                    context: context,
                    webpageMetadata: metadata
                )
                updater.execute()
            case let .rss(parsedFeed):
                let updater = RSSFeedMetaUpdate(
                    feed: feed,
                    feedData: feedData,
                    source: parsedFeed,
                    context: context,
                    webpageMetadata: metadata
                )
                updater.execute()
            case let .json(parsedFeed):
                let updater = JSONFeedMetaUpdate(
                    feed: feed,
                    feedData: feedData,
                    source: parsedFeed,
                    context: context,
                    webpageMetadata: metadata
                )
                updater.execute()
            }
            feedData.metaFetched = .now
        case .failure:
            return
        }
    }
    
    private func save(context: NSManagedObjectContext, feed: Feed) {
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                CrashUtility.handleCriticalError(error as NSError)
            }
        }
        
        if let start = start {
            let duration = CFAbsoluteTimeGetCurrent() - start
            Logger.ingest.info(
                "Feed updated in \(duration) seconds: \(feed.wrappedTitle, privacy: .public)"
            )
        }
    }
}
