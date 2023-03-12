//
//  FeedRefreshOperation.swift
//  Den
//
//  Created by Garrett Johnson on 10/30/22.
//  Copyright © 2022 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import CoreData

import FeedKit

struct FeedRefreshOperation {
    let container: NSPersistentContainer
    let feedObjectID: NSManagedObjectID
    let pageObjectID: NSManagedObjectID?
    let url: URL
    let updateMetadata: Bool

    // swiftlint:disable cyclomatic_complexity function_body_length
    func execute() async -> RefreshStatus {
        var refreshStatus = RefreshStatus()
        var parserResult: Result<FeedKit.Feed, FeedKit.ParserError>?
        var webpageMetadata: WebpageMetadata?

        if let (data, _) = try? await URLSession.shared.data(from: url) {
            parserResult = FeedParser(data: data).parse()
        }

        if updateMetadata {
            if
                case .success(let parsedFeed) = parserResult,
                let webpage = parsedFeed.webpage
            {
                let webpagMetadataOp = WebpageMetadataOperation(webpage: webpage)
                webpageMetadata = await webpagMetadataOp.execute()
            }
        }

        await container.performBackgroundTask { context in
            context.automaticallyMergesChangesFromParent = true
            context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy

            guard
                let feed = context.object(with: self.feedObjectID) as? Feed,
                let feedId = feed.id
            else { return }

            let feedData = feed.feedData ?? FeedData.create(in: context, feedId: feedId)

            switch parserResult {
            case .success(let parsedFeed):
                switch parsedFeed {
                case let .atom(parsedFeed):
                    let updater = AtomFeedUpdate(
                        feed: feed,
                        feedData: feedData,
                        source: parsedFeed,
                        webpageMetadata: webpageMetadata,
                        updateMetadata: updateMetadata,
                        context: context
                    )
                    updater.execute()
                case let .rss(parsedFeed):
                    let updater = RSSFeedUpdate(
                        feed: feed,
                        feedData: feedData,
                        source: parsedFeed,
                        webpageMetadata: webpageMetadata,
                        updateMetadata: updateMetadata,
                        context: context
                    )
                    updater.execute()
                case let .json(parsedFeed):
                    let updater = JSONFeedUpdate(
                        feed: feed,
                        feedData: feedData,
                        source: parsedFeed,
                        webpageMetadata: webpageMetadata,
                        updateMetadata: updateMetadata,
                        context: context
                    )
                    updater.execute()
                }
            case .failure:
                refreshStatus.errors.append("Unable to load content from [\(feed.urlString)](\(feed.urlString))")
            case .none:
                refreshStatus.errors.append("Unable to fetch data from [\(feed.urlString)](\(feed.urlString))")
            }

            // Cleanup items
            let maxItems = feed.wrappedItemLimit
            if feedData.itemsArray.count > maxItems {
                feedData.itemsArray.suffix(from: maxItems).forEach { item in
                    feedData.removeFromItems(item)
                    context.delete(item)
                }
            }

            // Update read flags
            for item in feedData.itemsArray {
                item.read = !item.history.isEmpty
            }

            // Update metadata and status
            if updateMetadata {
                feedData.metaFetched = .now
            }
            feedData.refreshed = .now
            feedData.error = refreshStatus.errors.first

            do {
                try context.save()
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

        return refreshStatus
    }
}
