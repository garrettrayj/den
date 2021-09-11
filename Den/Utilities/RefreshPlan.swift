//
//  RefreshPlan.swift
//  Den
//
//  Created by Garrett Johnson on 7/11/21.
//  Copyright © 2021 Garrett Johnson. All rights reserved.
//

import CoreData

// swiftlint:disable type_body_length
final class RefreshPlan {
    public var fullUpdate: Bool = false

    private var feed: Feed
    private var feedData: FeedData
    private var persistentContainer: NSPersistentContainer
    private var crashManager: CrashManager
    private var progress: Progress?

    // Feed processing operations
    private var fetchOp: DataTaskOperation?
    private var parseOp: ParseFeedDataOperation?
    private var webpageDataOp: DataTaskOperation?
    private var metadataOp: MetadataOperation?
    private var defaultFaviconDataOp: DataTaskOperation?
    private var webpageFaviconDataOp: DataTaskOperation?
    private var saveFaviconOp: SaveFaviconOperation?
    private var downloadThumbnailsOp: DownloadThumbnailsOperation?
    private var saveFeedOp: SaveFeedOperation?
    private var completionOp: BlockOperation?

    // Adapter operations pass data between processing operations in a concurrency-friendly way
    private var fetchParseAdapter: BlockOperation?
    private var parseWebpageAdapter: BlockOperation?
    private var webpageMetadataAdapter: BlockOperation?
    private var metadataDefaultFaviconDataAdapter: BlockOperation?
    private var metadataWebpageFaviconDataAdapter: BlockOperation?
    private var saveFaviconAdapter: BlockOperation?
    private var parseDownloadThumbnailsAdapter: BlockOperation?
    private var saveFeedAdapter: BlockOperation?

    init(
        feed: Feed,
        feedData: FeedData,
        persistentContainer: NSPersistentContainer,
        crashManager: CrashManager,
        progress: Progress? = nil
    ) {
        self.feed = feed
        self.feedData = feedData
        self.persistentContainer = persistentContainer
        self.crashManager = crashManager
        self.progress = progress
    }

    public func configureOps() {
        guard
            let feedUrl = feed.url,
            let itemLimit = feed.page?.wrappedItemsPerFeed
        else {
            return
        }

        let existingItemLinks = feedData.itemsArray.map({ item in
            return item.link!
        })

        addStandardProcessingOps(
            feedUrl: feedUrl,
            itemLimit: itemLimit,
            existingItemLinks: existingItemLinks,
            downloadImages: feed.showThumbnails
        )
        addStandardAdapters(downloadImages: feed.showThumbnails)
        wireStandardDependencies(downloadImages: feed.showThumbnails)

        if fullUpdate == true {
            addMetaProcessingOps()
            addMetaAdapters()
            wireMetaDependencies()
        }
    }

    private func addStandardProcessingOps(
        feedUrl: URL,
        itemLimit: Int,
        existingItemLinks: [URL],
        downloadImages: Bool
    ) {
        fetchOp = DataTaskOperation(feedUrl)
        parseOp = ParseFeedDataOperation(
            feedUrl: feedUrl,
            itemLimit: itemLimit,
            existingItemLinks: existingItemLinks,
            feedId: feed.id!
        )

        if downloadImages { downloadThumbnailsOp = DownloadThumbnailsOperation() }

        saveFeedOp = SaveFeedOperation(
            persistentContainer: persistentContainer,
            crashManager: crashManager,
            feedObjectID: feed.objectID,
            saveMeta: fullUpdate
        )
        completionOp = BlockOperation { [unowned progress] in
            DispatchQueue.main.async {
                progress?.completedUnitCount += 1
            }
        }
    }

    private func addMetaProcessingOps() {
        webpageDataOp = DataTaskOperation()
        metadataOp = MetadataOperation()
        defaultFaviconDataOp = DataTaskOperation()
        webpageFaviconDataOp = DataTaskOperation()
        saveFaviconOp = SaveFaviconOperation()
    }

    private func addStandardAdapters(downloadImages: Bool) {
        fetchParseAdapter = BlockOperation { [unowned fetchOp, unowned parseOp] in
            parseOp?.httpResponse = fetchOp?.response
            parseOp?.httpTransportError = fetchOp?.error
            parseOp?.data = fetchOp?.data
        }

        if downloadImages {
            parseDownloadThumbnailsAdapter = BlockOperation { [unowned parseOp, unowned downloadThumbnailsOp] in
                downloadThumbnailsOp?.inputWorkingItems = parseOp?.workingItems ?? []
            }

            // swiftlint:disable closure_parameter_position
            saveFeedAdapter =
                BlockOperation {[
                    unowned saveFeedOp,
                    unowned downloadThumbnailsOp,
                    unowned parseOp,
                    unowned saveFaviconOp
                ] in
                    saveFeedOp?.workingFeed = saveFaviconOp?.workingFeed ?? parseOp?.workingFeed
                    saveFeedOp?.workingFeedItems = downloadThumbnailsOp?.outputWorkingItems ?? []
                }
        } else {
            // swiftlint:disable closure_parameter_position
            saveFeedAdapter =
                BlockOperation {[
                    unowned saveFeedOp,
                    unowned parseOp,
                    unowned saveFaviconOp
                ] in
                    saveFeedOp?.workingFeed = saveFaviconOp?.workingFeed ?? parseOp?.workingFeed
                    saveFeedOp?.workingFeedItems = parseOp?.workingItems ?? []
                }
        }
    }

    private func addMetaAdapters() {
        parseWebpageAdapter = BlockOperation { [unowned parseOp, unowned webpageDataOp] in
            webpageDataOp?.url = parseOp?.workingFeed.link
        }

        webpageMetadataAdapter = BlockOperation { [unowned metadataOp, unowned webpageDataOp] in
            metadataOp?.webpageUrl = webpageDataOp?.url
            metadataOp?.webpageData = webpageDataOp?.data
        }

        metadataDefaultFaviconDataAdapter = BlockOperation { [unowned metadataOp, unowned defaultFaviconDataOp] in
            defaultFaviconDataOp?.url = metadataOp?.defaultFavicon
        }

        metadataWebpageFaviconDataAdapter = BlockOperation { [unowned metadataOp, unowned webpageFaviconDataOp] in
            webpageFaviconDataOp?.url = metadataOp?.webpageFavicon
        }

        saveFaviconAdapter =
            BlockOperation {[
                unowned defaultFaviconDataOp,
                unowned webpageFaviconDataOp,
                unowned saveFaviconOp,
                unowned parseOp
            ] in
                saveFaviconOp?.workingFeed = parseOp?.workingFeed
                saveFaviconOp?.defaultFaviconData = defaultFaviconDataOp?.data
                saveFaviconOp?.defaultFaviconResponse = defaultFaviconDataOp?.response
                saveFaviconOp?.webpageFaviconData = webpageFaviconDataOp?.data
                saveFaviconOp?.webpageFaviconResponse = webpageFaviconDataOp?.response
            }
    }

    private func wireStandardDependencies(downloadImages: Bool) {
        guard
            let fetchOp = fetchOp,
            let fetchParseAdapter = fetchParseAdapter,
            let parseOp = parseOp,
            let saveFeedAdapter = saveFeedAdapter,
            let saveFeedOp = saveFeedOp,
            let completionOp = completionOp
        else {
            preconditionFailure("Cannot wire standard dependencies due to operations not being configured.")
        }

        // Initial common dependencies
        fetchParseAdapter.addDependency(fetchOp)
        parseOp.addDependency(fetchParseAdapter)

        // Conditional dependencies
        if downloadImages {
            guard
                let parseDownloadThumbnailsAdapter = parseDownloadThumbnailsAdapter,
                let downloadThumbnailsOp = downloadThumbnailsOp
            else {
                preconditionFailure("Cannot wire image download dependencies, missing download operation.")
            }
            parseDownloadThumbnailsAdapter.addDependency(parseOp)
            downloadThumbnailsOp.addDependency(parseDownloadThumbnailsAdapter)
            saveFeedAdapter.addDependency(downloadThumbnailsOp)
        } else {
            saveFeedAdapter.addDependency(parseOp)
        }

        // Final common dependencies
        saveFeedOp.addDependency(saveFeedAdapter)
        completionOp.addDependency(saveFeedOp)
    }

    private func wireMetaDependencies() {
        guard
            let parseOp = parseOp,
            let saveFeedAdapter = saveFeedAdapter,
            let parseWebpageAdapter = parseWebpageAdapter,
            let webpageDataOp = webpageDataOp,
            let webpageMetadataAdapter = webpageMetadataAdapter,
            let metadataOp = metadataOp,
            let metadataDefaultFaviconDataAdapter = metadataDefaultFaviconDataAdapter,
            let defaultFaviconDataOp = defaultFaviconDataOp,
            let metadataWebpageFaviconDataAdapter = metadataWebpageFaviconDataAdapter,
            let webpageFaviconDataOp = webpageFaviconDataOp,
            let saveFaviconAdapter = saveFaviconAdapter,
            let saveFaviconOp = saveFaviconOp
        else {
            preconditionFailure("Cannot wire standard dependencies due to operations not being configured.")
        }

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
        saveFeedAdapter.addDependency(saveFaviconOp)
    }

    func getOps() -> [Operation] {
        return [
            fetchOp,
            fetchParseAdapter,
            parseOp,
            parseWebpageAdapter,
            webpageDataOp,
            webpageMetadataAdapter,
            metadataOp,
            metadataDefaultFaviconDataAdapter,
            defaultFaviconDataOp,
            metadataWebpageFaviconDataAdapter,
            webpageFaviconDataOp,
            saveFaviconAdapter,
            saveFaviconOp,
            parseDownloadThumbnailsAdapter,
            downloadThumbnailsOp,
            saveFeedAdapter,
            saveFeedOp,
            completionOp
        ].compactMap { $0 }
    }
}
