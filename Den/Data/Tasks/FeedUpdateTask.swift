//
//  FeedUpdateTask.swift
//  Den
//
//  Created by Garrett Johnson on 10/30/22.
//  Copyright © 2022 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftData
import OSLog

import FeedKit

struct FeedUpdateTask {
    let feedObjectID: PersistentIdentifier
    let url: URL
    let updateMeta: Bool

    // swiftlint:disable cyclomatic_complexity function_body_length
    func execute() async {
        let start = CFAbsoluteTimeGetCurrent()
        
        var parsedSuccessfully: Bool = false
        var parserResult: Result<FeedKit.Feed, FeedKit.ParserError>?
        var webpage: URL?

        let modelContext = ModelContext(DataController.shared.container)
        
        guard
            let feed = modelContext.model(for: self.feedObjectID) as? Feed,
            let feedId = feed.id
        else {
            Logger.main.error("Unable to fetch feed in update context.")
            return
        }

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

        let feedData = feed.feedData ?? FeedData.create(in: modelContext, feedId: feedId)
        feedData.refreshed = .now
        feedData.responseTime = feedResponse.responseTime
        feedData.httpStatus = feedResponse.statusCode
        feedData.server = feedResponse.server
        feedData.cacheControl = feedResponse.cacheControl
        feedData.age = feedResponse.age
        feedData.eTag = feedResponse.eTag
        
        guard (200...299).contains(feedData.httpStatus ?? 0) else {
            feedData.wrappedError = .request
            feedData.wrappedItems.forEach { modelContext.delete($0) }
            self.save(modelContext: modelContext, feed: feed, start: start)
            return
        }
        
        if let parserResult = parserResult {
            (parsedSuccessfully, webpage) = self.updateFeed(
                feed: feed,
                feedData: feedData,
                parserResult: parserResult,
                modelContext: modelContext
            )
        }

        // Cleanup old items
        if feedData.wrappedItems.count > Feed.totalItemLimit {
            feedData.sortedItems.suffix(from: Feed.totalItemLimit).forEach { item in
                modelContext.delete(item)
            }
        }

        // Update read and extra status of items
        for (idx, item) in feedData.sortedItems.enumerated() {
            item.read = !item.history.isEmpty

            if idx + 1 > feed.wrappedItemLimit {
                item.extra = true
            } else {
                item.extra = false
            }
        }

        if !self.updateMeta || !parsedSuccessfully {
            self.save(modelContext: modelContext, feed: feed, start: start)
        }

        if updateMeta && parsedSuccessfully {
            var webpageMetadata: WebpageMetadata?
            if let webpage = webpage {
                let webpageRequest = URLRequest(url: webpage)
                if let (data, _) = try? await URLSession.shared.data(for: webpageRequest) {
                    webpageMetadata = WebpageScraper.extractMetadata(
                        webpage: webpage,
                        data: data
                    )
                }
            }

            self.updateFeedMeta(
                feedData: feedData,
                parserResult: parserResult!,
                webpageMetadata: webpageMetadata
            )

            self.save(modelContext: modelContext, feed: feed, start: start)
        }
    }
    // swiftlint:enable cyclomatic_complexity function_body_length

    private func updateFeed(
        feed: Feed,
        feedData: FeedData,
        parserResult: Result<FeedKit.Feed, FeedKit.ParserError>,
        modelContext: ModelContext
    ) -> (Bool, URL?) {
        switch parserResult {
        case .success(let parsedFeed):
            feedData.error = nil
            
            switch parsedFeed {
            case let .atom(atomFeed):
                AtomFeedUpdater.updateFeed(
                    feed: feed,
                    feedData: feedData,
                    atomFeed: atomFeed,
                    modelContext: modelContext
                )
            case let .rss(rssFeed):
                RSSFeedUpdater.updateFeed(
                    feed: feed,
                    feedData: feedData,
                    rssFeed: rssFeed,
                    modelContext: modelContext
                )
            case let .json(jsonFeed):
                JSONFeedUpdater.updateFeed(
                    feed: feed,
                    feedData: feedData,
                    jsonFeed: jsonFeed,
                    modelContext: modelContext
                )
            }
            
            return (true, parsedFeed.webpage)
        case .failure:
            feedData.wrappedItems.forEach { modelContext.delete($0) }
            feedData.wrappedError = .parsing
            
            return (false, nil)
        }
    }

    private func updateFeedMeta(
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

    private func save(modelContext: ModelContext, feed: Feed, start: CFAbsoluteTime) {
        do {
            try modelContext.save()
            Logger.main.info("""
            Feed updated in \(CFAbsoluteTimeGetCurrent() - start) seconds: \
            \(feed.wrappedTitle, privacy: .public)
            """)
        } catch {
            CrashUtility.handleCriticalError(error as NSError)
        }
    }
}
