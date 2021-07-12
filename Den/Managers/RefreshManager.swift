//
//  RefreshManager.swift
//  Den
//
//  Created by Garrett Johnson on 8/16/20.
//  Copyright © 2020 Garrett Johnson. All rights reserved.
//

import CoreData
import OSLog

final class RefreshManager: ObservableObject {
    @Published public var refreshing: Bool = false

    public var progress = Progress(totalUnitCount: 0)

    private var queue = OperationQueue()
    private var persistentContainer: NSPersistentContainer
    private var crashManager: CrashManager

    init(persistentContainer: NSPersistentContainer, crashManager: CrashManager) {
        self.persistentContainer = persistentContainer
        self.crashManager = crashManager
    }

    public func refresh(_ page: Page) {
        page.feedsArray.forEach { feed in
            self.refresh(feed)
        }
    }

    public func refresh(_ feed: Feed) {
        refreshing = true
        progress.totalUnitCount += 1

        let feedData = self.checkFeedData(feed)

        var ops: [Operation] = []

        // Fetch meta (favicon, etc.) on first refresh or if user cleared cache, then check for updates occasionally
        if feedData.metaFetched == nil || feedData.metaFetched! < Date(timeIntervalSinceNow: -30 * 24 * 60 * 60) {
            ops = self.planFullUpdate(feed: feed, feedData: feedData)
        } else {
            ops = self.planContentUpdate(feed: feed, feedData: feedData)
        }

        DispatchQueue.global(qos: .userInitiated).async {
            self.queue.addOperations(ops, waitUntilFinished: false)
        }
    }

    private func checkFeedData(_ feed: Feed) -> FeedData {
        if feed.feedData == nil {
            let feed = FeedData.create(in: self.persistentContainer.viewContext, feedId: feed.id!)
            do {
                try self.persistentContainer.viewContext.save()
            } catch {
                DispatchQueue.main.async {
                    self.crashManager.handleCriticalError(error as NSError)
                }
            }

            return feed
        }

        return feed.feedData!
    }

    private func planFullUpdate(feed: Feed, feedData: FeedData) -> [Operation] {
        var ops: [Operation] = []

        guard
            let feedUrl = feed.url,
            let itemLimit = feed.page?.wrappedItemsPerFeed
        else {
            return []
        }

        let existingItemLinks = feedData.itemsArray.map({ item in
            return item.link!
        })

        // Create base ops
        let fetchOp = DataTaskOperation(feedUrl)
        let parseOp = ParseFeedDataOperation(
            feedUrl: feedUrl,
            itemLimit: itemLimit,
            existingItemLinks: existingItemLinks,
            feedId: feed.id!
        )
        let webpageDataOp = DataTaskOperation()
        let metadataOp = MetadataOperation()
        let defaultFaviconDataOp = DataTaskOperation()
        let webpageFaviconDataOp = DataTaskOperation()
        let saveFaviconOp = SaveFaviconOperation()
        let downloadThumbnailsOp = DownloadThumbnailsOperation()
        let saveFeedOp = SaveFeedOperation(
            persistentContainer: self.persistentContainer,
            crashManager: self.crashManager,
            feedObjectID: feed.objectID,
            saveMeta: true
        )

        let completionOp = BlockOperation {
            DispatchQueue.main.async {
                self.progress.completedUnitCount += 1
                if self.progress.isFinished {
                    self.refreshFinished(page: feed.page)
                }
            }
        }

        // Create adapters
        let fetchParseAdapter = BlockOperation { [unowned fetchOp, unowned parseOp] in
            parseOp.httpResponse = fetchOp.response
            parseOp.httpTransportError = fetchOp.error
            parseOp.data = fetchOp.data
        }

        let parseWebpageAdapter = BlockOperation { [unowned parseOp, unowned webpageDataOp] in
            webpageDataOp.url = parseOp.workingFeed.link
        }

        let webpageMetadataAdapter = BlockOperation { [unowned metadataOp, unowned webpageDataOp] in
            metadataOp.webpageUrl = webpageDataOp.url
            metadataOp.webpageData = webpageDataOp.data
        }

        let metadataDefaultFaviconDataAdapter = BlockOperation { [unowned metadataOp, unowned defaultFaviconDataOp] in
            defaultFaviconDataOp.url = metadataOp.defaultFavicon
        }

        let metadataWebpageFaviconDataAdapter = BlockOperation { [unowned metadataOp, unowned webpageFaviconDataOp] in
            webpageFaviconDataOp.url = metadataOp.webpageFavicon
        }

        let saveFaviconAdapter =
            BlockOperation {[unowned defaultFaviconDataOp, unowned webpageFaviconDataOp, unowned saveFaviconOp] in
                saveFaviconOp.workingFeed = parseOp.workingFeed
                saveFaviconOp.defaultFaviconData = defaultFaviconDataOp.data
                saveFaviconOp.defaultFaviconResponse = defaultFaviconDataOp.response
                saveFaviconOp.webpageFaviconData = webpageFaviconDataOp.data
                saveFaviconOp.webpageFaviconResponse = webpageFaviconDataOp.response
            }

        let parseDownloadThumbnailsAdapter = BlockOperation { [unowned parseOp, unowned downloadThumbnailsOp] in
            downloadThumbnailsOp.inputWorkingItems = parseOp.workingItems
        }

        let saveFeedAdapter = BlockOperation {[
                unowned saveFeedOp,
                unowned saveFaviconOp,
                unowned downloadThumbnailsOp
            ] in
            saveFeedOp.workingFeed = saveFaviconOp.workingFeed
            saveFeedOp.workingFeedItems = downloadThumbnailsOp.outputWorkingItems
        }

        // Dependency graph
        fetchParseAdapter.addDependency(fetchOp)
        parseOp.addDependency(fetchParseAdapter)
        parseWebpageAdapter.addDependency(parseOp)
        webpageDataOp.addDependency(parseWebpageAdapter)
        webpageMetadataAdapter.addDependency(webpageDataOp)
        metadataOp.addDependency(webpageMetadataAdapter)
        metadataDefaultFaviconDataAdapter.addDependency(metadataOp)
        metadataWebpageFaviconDataAdapter.addDependency(metadataOp)
        defaultFaviconDataOp.addDependency(metadataDefaultFaviconDataAdapter)
        webpageFaviconDataOp.addDependency(metadataWebpageFaviconDataAdapter)
        saveFaviconAdapter.addDependency(defaultFaviconDataOp)
        saveFaviconAdapter.addDependency(webpageFaviconDataOp)
        saveFaviconOp.addDependency(saveFaviconAdapter)
        parseDownloadThumbnailsAdapter.addDependency(parseOp)
        downloadThumbnailsOp.addDependency(parseDownloadThumbnailsAdapter)
        saveFeedAdapter.addDependency(downloadThumbnailsOp)
        saveFeedAdapter.addDependency(saveFaviconOp)
        saveFeedOp.addDependency(saveFeedAdapter)
        completionOp.addDependency(saveFeedOp)

        ops.append(fetchOp)
        ops.append(fetchParseAdapter)
        ops.append(parseOp)
        ops.append(parseWebpageAdapter)
        ops.append(webpageDataOp)
        ops.append(webpageMetadataAdapter)
        ops.append(metadataOp)
        ops.append(metadataDefaultFaviconDataAdapter)
        ops.append(defaultFaviconDataOp)
        ops.append(metadataWebpageFaviconDataAdapter)
        ops.append(webpageFaviconDataOp)
        ops.append(saveFaviconAdapter)
        ops.append(saveFaviconOp)
        ops.append(parseDownloadThumbnailsAdapter)
        ops.append(downloadThumbnailsOp)
        ops.append(saveFeedAdapter)
        ops.append(saveFeedOp)
        ops.append(completionOp)

        return ops
    }

    private func planContentUpdate(feed: Feed, feedData: FeedData) -> [Operation] {
        var ops: [Operation] = []

        guard
            let feedUrl = feed.url,
            let itemLimit = feed.page?.wrappedItemsPerFeed
        else {
            return []
        }

        let existingItemLinks = feedData.itemsArray.map({ item in
            return item.link!
        })

        // Create base ops
        let fetchOp = DataTaskOperation(feedUrl)
        let parseOp = ParseFeedDataOperation(
            feedUrl: feedUrl,
            itemLimit: itemLimit,
            existingItemLinks: existingItemLinks,
            feedId: feedData.id!
        )
        let downloadThumbnailsOp = DownloadThumbnailsOperation()
        let saveFeedOp = SaveFeedOperation(
            persistentContainer: self.persistentContainer,
            crashManager: self.crashManager,
            feedObjectID: feed.objectID,
            saveMeta: false
        )

        let completionOp = BlockOperation {
            DispatchQueue.main.async {
                self.progress.completedUnitCount += 1
                if self.progress.isFinished {
                    self.refreshFinished(page: feed.page)
                }
            }
        }

        // Create adapters
        let fetchParseAdapter = BlockOperation { [unowned fetchOp, unowned parseOp] in
            parseOp.httpResponse = fetchOp.response
            parseOp.httpTransportError = fetchOp.error
            parseOp.data = fetchOp.data
        }

        let parseDownloadThumbnailsAdapter = BlockOperation { [unowned parseOp, unowned downloadThumbnailsOp] in
            downloadThumbnailsOp.inputWorkingItems = parseOp.workingItems
        }

        let saveFeedAdapter = BlockOperation { [unowned saveFeedOp, unowned parseOp, unowned downloadThumbnailsOp] in
            saveFeedOp.workingFeed = parseOp.workingFeed
            saveFeedOp.workingFeedItems = downloadThumbnailsOp.outputWorkingItems
        }

        // Dependency graph
        fetchParseAdapter.addDependency(fetchOp)
        parseOp.addDependency(fetchParseAdapter)
        parseDownloadThumbnailsAdapter.addDependency(parseOp)
        downloadThumbnailsOp.addDependency(parseDownloadThumbnailsAdapter)
        saveFeedAdapter.addDependency(downloadThumbnailsOp)
        saveFeedAdapter.addDependency(parseOp)
        saveFeedOp.addDependency(saveFeedAdapter)
        completionOp.addDependency(saveFeedOp)

        ops.append(fetchOp)
        ops.append(fetchParseAdapter)
        ops.append(parseOp)
        ops.append(parseDownloadThumbnailsAdapter)
        ops.append(downloadThumbnailsOp)
        ops.append(saveFeedAdapter)
        ops.append(saveFeedOp)
        ops.append(completionOp)

        return ops
    }

    private func refreshFinished(page: Page?) {
        if self.persistentContainer.viewContext.hasChanges {
            do {
                try self.persistentContainer.viewContext.save()
            } catch let error as NSError {
                self.crashManager.handleCriticalError(error)
            }
        }

        page?.objectWillChange.send()

        self.refreshing = false
    }
}
