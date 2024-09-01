//
//  FeedUpdateTask.swift
//  Den
//
//  Created by Garrett Johnson on 10/30/22.
//  Copyright © 2022 Garrett Johnson. All rights reserved.
//

import CoreData
import OSLog

import FeedKit

struct FeedUpdateTask {
    // swiftlint:disable cyclomatic_complexity function_body_length
    static func execute(
        feedObjectID: NSManagedObjectID,
        url: URL,
        updateMeta: Bool
    ) async {
        let start = CFAbsoluteTimeGetCurrent()
        
        var parsedSuccessfully: Bool = false
        var parserResult: Result<FeedKit.Feed, FeedKit.ParserError>?
        var webpageMetadata: WebpageMetadata?
        
        let feedRequest = URLRequest(url: url)
        var feedResponse = FeedURLResponse()
        if let (data, urlResponse) = try? await URLSession.shared.data(for: feedRequest) {
            feedResponse.responseTime = Float(CFAbsoluteTimeGetCurrent() - start)
            if let httpResponse = urlResponse as? HTTPURLResponse {
                feedResponse.statusCode = Int16(httpResponse.statusCode)
                feedResponse.server = httpResponse.value(forHTTPHeaderField: "Server")
                feedResponse.cacheControl = httpResponse.value(forHTTPHeaderField: "Cache-Control")
                feedResponse.age = httpResponse.value(forHTTPHeaderField: "Age")
                feedResponse.eTag = httpResponse.value(forHTTPHeaderField: "ETag")
            }
            parserResult = FeedParser(data: data).parse()
        }
        
        switch parserResult {
        case .success(let parsedFeed):
            if updateMeta, let webpage = parsedFeed.webpage {
                let webpageRequest = URLRequest(url: webpage)
                if let (data, _) = try? await URLSession.shared.data(for: webpageRequest) {
                    webpageMetadata = WebpageScraper.extractMetadata(
                        webpage: webpage,
                        data: data
                    )
                }
            }
        case .failure:
            break
        case .none:
            break
        }

        let context = DataController.shared.container.newBackgroundContext()
        context.mergePolicy = NSMergePolicy(merge: .mergeByPropertyObjectTrumpMergePolicyType)
        
        context.performAndWait {
            guard
                let feed = context.object(with: feedObjectID) as? Feed,
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
            
            guard (200...299).contains(feedData.httpStatus) else {
                feedData.wrappedError = .request
                feedData.itemsArray.forEach { context.delete($0) }
                self.save(context: context, feed: feed, start: start)
                return
            }
            
            if let parserResult = parserResult {
                parsedSuccessfully = updateFeed(
                    feed: feed,
                    feedData: feedData,
                    parserResult: parserResult,
                    context: context
                )
            }

            // Cleanup old items
            if feedData.itemsArray.count > Feed.totalItemLimit {
                feedData.itemsArray.suffix(from: Feed.totalItemLimit).forEach { item in
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

            if !updateMeta || !parsedSuccessfully {
                self.save(context: context, feed: feed, start: start)
            }

            if updateMeta && parsedSuccessfully {
                self.updateFeedMeta(
                    feedData: feedData,
                    parserResult: parserResult!,
                    webpageMetadata: webpageMetadata
                )

                self.save(context: context, feed: feed, start: start)
            }
        }
    }
    // swiftlint:enable cyclomatic_complexity function_body_length

    static private func updateFeed(
        feed: Feed,
        feedData: FeedData,
        parserResult: Result<FeedKit.Feed, FeedKit.ParserError>,
        context: NSManagedObjectContext
    ) -> Bool {
        switch parserResult {
        case .success(let parsedFeed):
            feedData.error = nil
            
            switch parsedFeed {
            case let .atom(atomFeed):
                AtomFeedUpdater.updateFeed(
                    feed: feed,
                    feedData: feedData,
                    atomFeed: atomFeed,
                    context: context
                )
            case let .rss(rssFeed):
                RSSFeedUpdater.updateFeed(
                    feed: feed,
                    feedData: feedData,
                    rssFeed: rssFeed,
                    context: context
                )
            case let .json(jsonFeed):
                JSONFeedUpdater.updateFeed(
                    feed: feed,
                    feedData: feedData,
                    jsonFeed: jsonFeed,
                    context: context
                )
            }
            
            return true
        case .failure:
            feedData.itemsArray.forEach { context.delete($0) }
            feedData.wrappedError = .parsing
            
            return false
        }
    }

    static private func updateFeedMeta(
        feedData: FeedData,
        parserResult: Result<FeedKit.Feed, FeedKit.ParserError>,
        webpageMetadata: WebpageMetadata? = nil
    ) {
        switch parserResult {
        case .success(let parsedFeed):
            switch parsedFeed {
            case let .atom(atomFeed):
                AtomFeedUpdater.updateMeta(
                    feedData: feedData,
                    atomFeed: atomFeed,
                    webpageMetadata: webpageMetadata
                )
            case let .rss(rssFeed):
                RSSFeedUpdater.updateMeta(
                    feedData: feedData,
                    rssFeed: rssFeed,
                    webpageMetadata: webpageMetadata
                )
            case let .json(jsonFeed):
                JSONFeedUpdater.updateMeta(
                    feedData: feedData,
                    jsonFeed: jsonFeed,
                    webpageMetadata: webpageMetadata
                )
            }
            
            feedData.metaFetched = .now
        case .failure:
            return
        }
    }

    static private func save(context: NSManagedObjectContext, feed: Feed, start: CFAbsoluteTime) {
        do {
            try context.save()
            Logger.main.info("""
            Feed updated in \(CFAbsoluteTimeGetCurrent() - start) seconds: \
            \(feed.wrappedTitle, privacy: .public)
            """)
        } catch {
            CrashUtility.handleCriticalError(error as NSError)
        }
    }
}
