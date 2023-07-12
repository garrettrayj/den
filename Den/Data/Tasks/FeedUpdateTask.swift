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

struct FeedUpdateTask {
    let feedObjectID: NSManagedObjectID
    let pageObjectID: NSManagedObjectID?
    let url: URL
    let updateMetadata: Bool
    let timeout: TimeInterval

    // swiftlint:disable cyclomatic_complexity function_body_length
    func execute() async {
        let start = CFAbsoluteTimeGetCurrent()
        var parserResult: Result<FeedKit.Feed, FeedKit.ParserError>?
        var webpageMetadata: WebpageMetadata?

        let feedRequest = URLRequest(url: url, timeoutInterval: timeout)

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

        if updateMetadata {
            if
                case .success(let parsedFeed) = parserResult,
                let webpage = parsedFeed.webpage
            {
                let webpageRequest = URLRequest(url: webpage, timeoutInterval: timeout)
                if let (webpageData, _) = try? await URLSession.shared.data(for: webpageRequest) {
                    webpageMetadata = WebpageMetadata.from(webpage: webpage, data: webpageData)
                }
            }
        }

        await PersistenceController.shared.container.performBackgroundTask { context in
            context.automaticallyMergesChangesFromParent = true
            context.mergePolicy = NSMergePolicy(merge: .mergeByPropertyStoreTrumpMergePolicyType)

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

            switch parserResult {
            case .success(let parsedFeed):
                handleParsedFeed(
                    parsedFeed: parsedFeed,
                    feed: feed,
                    feedData: feedData,
                    context: context,
                    webpageMetadata: webpageMetadata
                )
                feedData.error = nil
            case .failure:
                feedData.error = RefreshError.parsing.rawValue
            case .none:
                feedData.error = RefreshError.request.rawValue
            }

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

            do {
                try context.save()
                let duration = CFAbsoluteTimeGetCurrent() - start
                Logger.ingest.info("Feed updated in \(duration) seconds: \(feed.wrappedTitle, privacy: .public)")

                DispatchQueue.main.async {
                    NotificationCenter.default.post(
                        name: .feedRefreshed,
                        object: self.feedObjectID,
                        userInfo: ["pageObjectID": pageObjectID as Any]
                    )
                }
            } catch {
                CrashUtility.handleCriticalError(error as NSError)
            }
        }
    }

    private func handleParsedFeed(
        parsedFeed: FeedKit.Feed,
        feed: Feed,
        feedData: FeedData,
        context: NSManagedObjectContext,
        webpageMetadata: WebpageMetadata?
    ) {
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

        if updateMetadata {
            switch parsedFeed {
            case let .atom(parsedFeed):
                let updater = AtomFeedMetaUpdate(
                    feed: feed,
                    feedData: feedData,
                    source: parsedFeed,
                    context: context,
                    webpageMetadata: webpageMetadata
                )
                updater.execute()
            case let .rss(parsedFeed):
                let updater = RSSFeedMetaUpdate(
                    feed: feed,
                    feedData: feedData,
                    source: parsedFeed,
                    context: context,
                    webpageMetadata: webpageMetadata
                )
                updater.execute()
            case let .json(parsedFeed):
                let updater = JSONFeedMetaUpdate(
                    feed: feed,
                    feedData: feedData,
                    source: parsedFeed,
                    context: context,
                    webpageMetadata: webpageMetadata
                )
                updater.execute()
            }
            feedData.metaFetched = .now
        }
    }
}
