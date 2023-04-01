//
//  FeedUpdateOperation.swift
//  Den
//
//  Created by Garrett Johnson on 3/31/23.
//  Copyright © 2023 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import CoreData
import OSLog

import FeedKit

final class FeedUpdateOperation: AsynchronousOperation {
    let feedURL: URL
    let feedObjectID: NSManagedObjectID
    let updateMeta: Bool

    private var feedTask: URLSessionTask?
    private var webpageTask: URLSessionTask?
    private var start: Double?

    init(feedURL: URL, feedObjectID: NSManagedObjectID, updateMeta: Bool) {
        self.feedURL = feedURL
        self.feedObjectID = feedObjectID
        self.updateMeta = updateMeta
        super.init()
    }

    override func cancel() {
        feedTask?.cancel()
        webpageTask?.cancel()
        super.cancel()
    }

    // swiftlint:disable function_body_length
    override func main() {
        start = CFAbsoluteTimeGetCurrent()
        let feedRequest = URLRequest(url: feedURL)
        var parserResult: Result<FeedKit.Feed, FeedKit.ParserError>?

        feedTask = URLSession.shared.dataTask(
            with: feedRequest,
            completionHandler: { [self] data, _, _ in
                PersistenceController.shared.container.performBackgroundTask { context in
                    context.automaticallyMergesChangesFromParent = true
                    context.mergePolicy = NSMergePolicy(merge: .mergeByPropertyStoreTrumpMergePolicyType)

                    guard
                        let feed = context.object(with: self.feedObjectID) as? Feed,
                        let feedID = feed.id
                    else {
                        self.finish()
                        return
                    }

                    let feedData = feed.feedData ?? FeedData.create(in: context, feedId: feedID)
                    feedData.refreshed = .now
                    guard let data = data else {
                        feedData.error = "Unable to fetch content from [\(feed.urlString)](\(feed.urlString))"
                        self.save(context: context, feed: feed)
                        self.finish()
                        return
                    }

                    parserResult = FeedParser(data: data).parse()
                    self.updateFeed(
                        feed: feed,
                        feedData: feedData,
                        parserResult: parserResult!,
                        context: context
                    )

                    // Cleanup old items
                    let maxItems = feed.wrappedItemLimit + AppDefaults.extraItemLimit
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

                    if self.updateMeta, let webpage = feedData.link {
                        let webpageRequest = URLRequest(url: webpage)
                        self.webpageTask = URLSession.shared.dataTask(
                            with: webpageRequest,
                            completionHandler: { [self] data, _, _ in
                                let metadata = WebpageMetadata.from(webpage: webpage, data: data)
                                self.updateMetadata(
                                    feed: feed,
                                    feedData: feedData,
                                    parserResult: parserResult!,
                                    context: context,
                                    metadata: metadata
                                )
                                self.save(context: context, feed: feed)
                                self.finish()
                            }
                        )
                        self.webpageTask?.resume()
                    } else if self.updateMeta {
                        self.updateMetadata(
                            feed: feed,
                            feedData: feedData,
                            parserResult: parserResult!,
                            context: context
                        )
                        self.save(context: context, feed: feed)
                        self.finish()
                    } else {
                        self.save(context: context, feed: feed)
                        self.finish()
                    }
                }
            }
        )
        feedTask?.resume()
    }

    private func updateFeed(
        feed: Feed,
        feedData: FeedData,
        parserResult: Result<FeedKit.Feed, FeedKit.ParserError>,
        context: NSManagedObjectContext
    ) {
        switch parserResult {
        case .success(let parsedFeed):
            switch parsedFeed {
            case let .atom(parsedFeed):
                let updater = AtomFeedUpdate(
                    feed: feed,
                    feedData: feedData,
                    source: parsedFeed,
                    context: context
                )
                updater.execute()
            case let .rss(parsedFeed):
                let updater = RSSFeedUpdate(
                    feed: feed,
                    feedData: feedData,
                    source: parsedFeed,
                    context: context
                )
                updater.execute()
            case let .json(parsedFeed):
                let updater = JSONFeedUpdate(
                    feed: feed,
                    feedData: feedData,
                    source: parsedFeed,
                    context: context
                )
                updater.execute()
            }
        case .failure:
            feedData.error = "Unable to load content from [\(feed.urlString)](\(feed.urlString))"
            return
        }
    }

    private func updateMetadata(
        feed: Feed,
        feedData: FeedData,
        parserResult: Result<FeedKit.Feed, FeedKit.ParserError>,
        context: NSManagedObjectContext,
        metadata: WebpageMetadata? = nil
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
        do {
            try context.save()
            if let start = start {
                let duration = CFAbsoluteTimeGetCurrent() - start
                Logger.ingest.info("Feed updated in \(duration) seconds: \(feed.wrappedTitle)")
            }
        } catch {
            CrashUtility.handleCriticalError(error as NSError)
        }
    }
}
