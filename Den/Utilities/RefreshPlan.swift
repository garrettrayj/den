//
//  RefreshPlan.swift
//  Den
//
//  Created by Garrett Johnson on 7/11/21.
//  Copyright © 2021 Garrett Johnson. All rights reserved.
//

import CoreData

final class RefreshPlan {
    let feed: Feed
    let feedData: FeedData
    let persistentContainer: NSPersistentContainer

    // Feed processing operations
    private var fetchOp: DataTaskOperation?
    private var parseOp: ParseFeedDataOperation?
    private var webpageDataOp: DataTaskOperation?
    private var webMetaOp: WebMetaOperation?
    private var defaultFaviconDataOp: DataTaskOperation?
    private var webpageFaviconDataOp: DataTaskOperation?
    private var feedMetaOp: FeedMetaOperation?

    // Adapter operations pass data between processing operations in a concurrency-friendly way
    private var fetchParseAdapter: BlockOperation?
    private var parseWebpageAdapter: BlockOperation?
    private var webpageMetadataAdapter: BlockOperation?
    private var metadataDefaultFaviconDataAdapter: BlockOperation?
    private var metadataWebpageFaviconDataAdapter: BlockOperation?
    private var saveFaviconAdapter: BlockOperation?
    private var parseDownloadThumbnailsAdapter: BlockOperation?
    private var saveFeedAdapter: BlockOperation?

    public var fullUpdate: Bool = false

    // Save operation is public so it may be added as a dependency for feed completion op
    public var saveFeedOp: SaveFeedOperation?

    init(
        feed: Feed,
        feedData: FeedData,
        persistentContainer: NSPersistentContainer
    ) {
        self.feed = feed
        self.feedData = feedData
        self.persistentContainer = persistentContainer
    }

    func configureOps() {
        guard let feedUrl = feed.url else {
            return
        }

        let existingItemLinks = feedData.itemsArray.compactMap({ item in
            return item.link
        })

        addStandardProcessingOps(
            feedUrl: feedUrl,
            itemLimit: 100,
            existingItemLinks: existingItemLinks
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
        existingItemLinks: [URL]
    ) {
        fetchOp = DataTaskOperation(feedUrl)
        parseOp = ParseFeedDataOperation(
            feedUrl: feedUrl,
            itemLimit: itemLimit,
            existingItemLinks: existingItemLinks,
            feedId: feed.id!
        )

        saveFeedOp = SaveFeedOperation(
            persistentContainer: persistentContainer,
            feedObjectID: feed.objectID,
            saveMeta: fullUpdate
        )
    }

    private func addMetaProcessingOps() {
        webpageDataOp = DataTaskOperation()
        webMetaOp = WebMetaOperation()
        defaultFaviconDataOp = DataTaskOperation()
        webpageFaviconDataOp = DataTaskOperation()
        feedMetaOp = FeedMetaOperation()
    }

    private func addStandardAdapters(downloadImages: Bool) {
        fetchParseAdapter = BlockOperation { [unowned fetchOp, unowned parseOp] in
            parseOp?.httpResponse = fetchOp?.response
            parseOp?.httpTransportError = fetchOp?.error
            parseOp?.data = fetchOp?.data
        }

        saveFeedAdapter =
            BlockOperation {[
                unowned saveFeedOp,
                unowned parseOp,
                unowned feedMetaOp
            ] in
                saveFeedOp?.workingFeed = feedMetaOp?.workingFeed ?? parseOp?.workingFeed
                saveFeedOp?.workingFeedItems = parseOp?.workingItems ?? []
            }
    }

    private func addMetaAdapters() {
        parseWebpageAdapter = BlockOperation { [unowned parseOp, unowned webpageDataOp] in
            webpageDataOp?.url = parseOp?.workingFeed.link
        }

        webpageMetadataAdapter = BlockOperation { [unowned webMetaOp, unowned webpageDataOp] in
            webMetaOp?.webpageUrl = webpageDataOp?.url
            webMetaOp?.webpageData = webpageDataOp?.data
        }

        metadataDefaultFaviconDataAdapter = BlockOperation { [unowned webMetaOp, unowned defaultFaviconDataOp] in
            defaultFaviconDataOp?.url = webMetaOp?.defaultFavicon
        }

        metadataWebpageFaviconDataAdapter = BlockOperation { [unowned webMetaOp, unowned webpageFaviconDataOp] in
            webpageFaviconDataOp?.url = webMetaOp?.webpageFavicon
        }

        saveFaviconAdapter =
            BlockOperation {[
                unowned defaultFaviconDataOp,
                unowned webpageFaviconDataOp,
                unowned feedMetaOp,
                unowned parseOp
            ] in
                feedMetaOp?.workingFeed = parseOp?.workingFeed
                feedMetaOp?.defaultFaviconData = defaultFaviconDataOp?.data
                feedMetaOp?.defaultFaviconResponse = defaultFaviconDataOp?.response
                feedMetaOp?.webpageFaviconData = webpageFaviconDataOp?.data
                feedMetaOp?.webpageFaviconResponse = webpageFaviconDataOp?.response
            }
    }

    private func wireStandardDependencies(downloadImages: Bool) {
        guard
            let fetchOp = fetchOp,
            let fetchParseAdapter = fetchParseAdapter,
            let parseOp = parseOp,
            let saveFeedAdapter = saveFeedAdapter,
            let saveFeedOp = saveFeedOp
        else {
            preconditionFailure("Cannot wire standard dependencies due to operations not being configured.")
        }

        fetchParseAdapter.addDependency(fetchOp)
        parseOp.addDependency(fetchParseAdapter)
        saveFeedAdapter.addDependency(parseOp)
        saveFeedOp.addDependency(saveFeedAdapter)
    }

    private func wireMetaDependencies() {
        guard
            let parseOp = parseOp,
            let saveFeedAdapter = saveFeedAdapter,
            let parseWebpageAdapter = parseWebpageAdapter,
            let webpageDataOp = webpageDataOp,
            let webpageMetadataAdapter = webpageMetadataAdapter,
            let webMetaOp = webMetaOp,
            let metadataDefaultFaviconDataAdapter = metadataDefaultFaviconDataAdapter,
            let defaultFaviconDataOp = defaultFaviconDataOp,
            let metadataWebpageFaviconDataAdapter = metadataWebpageFaviconDataAdapter,
            let webpageFaviconDataOp = webpageFaviconDataOp,
            let saveFaviconAdapter = saveFaviconAdapter,
            let feedMetaOp = feedMetaOp
        else {
            preconditionFailure("Cannot wire standard dependencies due to operations not being configured.")
        }

        parseWebpageAdapter.addDependency(parseOp)
        webpageDataOp.addDependency(parseWebpageAdapter)
        webpageMetadataAdapter.addDependency(webpageDataOp)
        webMetaOp.addDependency(webpageMetadataAdapter)
        metadataDefaultFaviconDataAdapter.addDependency(webMetaOp)
        metadataWebpageFaviconDataAdapter.addDependency(webMetaOp)
        defaultFaviconDataOp.addDependency(metadataDefaultFaviconDataAdapter)
        webpageFaviconDataOp.addDependency(metadataWebpageFaviconDataAdapter)
        saveFaviconAdapter.addDependency(defaultFaviconDataOp)
        saveFaviconAdapter.addDependency(webpageFaviconDataOp)
        feedMetaOp.addDependency(saveFaviconAdapter)
        saveFeedAdapter.addDependency(feedMetaOp)
    }

    func getOps() -> [Operation] {
        return [
            fetchOp,
            fetchParseAdapter,
            parseOp,
            parseWebpageAdapter,
            webpageDataOp,
            webpageMetadataAdapter,
            webMetaOp,
            metadataDefaultFaviconDataAdapter,
            defaultFaviconDataOp,
            metadataWebpageFaviconDataAdapter,
            webpageFaviconDataOp,
            saveFaviconAdapter,
            feedMetaOp,
            parseDownloadThumbnailsAdapter,
            saveFeedAdapter,
            saveFeedOp
        ].compactMap { $0 }
    }
}
