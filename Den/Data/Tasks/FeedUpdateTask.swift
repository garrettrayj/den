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

    // swiftlint:disable cyclomatic_complexity function_body_length
    func execute() async {
        let start = CFAbsoluteTimeGetCurrent()
        var parserResult: Result<FeedKit.Feed, FeedKit.ParserError>?
        var webpageMetadata: WebpageMetadata?

        let feedRequest = URLRequest(url: url, timeoutInterval: AppDefaults.requestTimeout)
        if let (data, _) = try? await URLSession.shared.data(for: feedRequest) {
            parserResult = FeedParser(data: data).parse()
        }

        if updateMetadata {
            if
                case .success(let parsedFeed) = parserResult,
                let webpage = parsedFeed.webpage
            {
                let webpageRequest = URLRequest(url: webpage, timeoutInterval: AppDefaults.requestTimeout)
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

            switch parserResult {
            case .success(let parsedFeed):
                handleParsedFeed(
                    parsedFeed: parsedFeed,
                    feed: feed,
                    feedData: feedData,
                    context: context,
                    webpageMetadata: webpageMetadata
                )
            case .failure:
                feedData.error = "Unable to load content from [\(feed.urlString)](\(feed.urlString))"
            case .none:
                feedData.error = "Unable to fetch data from [\(feed.urlString)](\(feed.urlString))"
            }

            // Cleanup old items
            let maxItems = feed.cascadedItemLimit + AppDefaults.extraItemLimit
            if feedData.itemsArray.count > maxItems {
                feedData.itemsArray.suffix(from: maxItems).forEach { item in
                    feedData.removeFromItems(item)
                    context.delete(item)
                }
            }

            // Update read and extra status of items
            for (idx, item) in feedData.itemsArray.enumerated() {
                item.read = !item.history.isEmpty

                if idx + 1 > feed.cascadedItemLimit {
                    item.extra = true
                } else {
                    item.extra = false
                }
            }

            feedData.refreshed = .now

            do {
                try context.save()
                let duration = CFAbsoluteTimeGetCurrent() - start
                Logger.ingest.info("Feed updated in \(duration) seconds: \(feed.wrappedTitle)")
            } catch {
                CrashUtility.handleCriticalError(error as NSError)
            }
        }

        DispatchQueue.main.async {
            NotificationCenter.default.post(
                name: .feedRefreshed,
                object: self.feedObjectID,
                userInfo: ["pageObjectID": pageObjectID as Any]
            )
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
