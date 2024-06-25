//
//  LatestItemsProvider.swift
//  Den
//
//  Created by Garrett Johnson on 5/5/24.
//  Copyright © 2024 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import Foundation
import SwiftData
import WidgetKit
import SwiftUI

import CompoundPredicate
import SDWebImage
import SDWebImageSVGCoder
import SDWebImageWebPCoder

struct LatestItemsProvider: AppIntentTimelineProvider {
    init() {
        SDImageCodersManager.shared.addCoder(SDImageSVGCoder.shared)
        SDImageCodersManager.shared.addCoder(SDImageWebPCoder.shared)
    }
    
    func placeholder(in context: Context) -> LatestItemsEntry {
        LatestItemsEntry(
            date: Date(),
            items: [], 
            sourceID: nil,
            sourceType: nil,
            unread: 10,
            title: Text("Inbox", comment: "Widget placeholder title."),
            faviconURL: nil,
            faviconImage: nil,
            symbol: "tray",
            configuration: LatestItemsConfigurationIntent(
                source: SourceQuery.defaultSource
            )
        )
    }

    func snapshot(
        for configuration: LatestItemsConfigurationIntent,
        in context: Context
    ) async -> LatestItemsEntry {
        LatestItemsEntry(
            date: Date(),
            items: [],
            sourceID: nil,
            sourceType: nil,
            unread: 10,
            title: Text("Inbox", comment: "Widget snapshot title."),
            faviconURL: nil,
            faviconImage: nil,
            symbol: "tray",
            configuration: configuration
        )
    }
    
    // swiftlint:disable cyclomatic_complexity function_body_length
    func timeline(
        for configuration: LatestItemsConfigurationIntent,
        in context: Context
    ) async -> Timeline<LatestItemsEntry> {
        var entries: [LatestItemsEntry] = []
        
        let moc = ModelContext(DataController.shared.container)

        var feed: Feed?
        var page: Page?

        // Fetch scope object
        let sourceID = configuration.source.id as String?
        if configuration.source.entityType == Page.self {
            let request = FetchDescriptor<Page>(
                predicate: #Predicate<Page> { $0.id?.uuidString == sourceID }
            )
            page = try? moc.fetch(request).first
        } else if configuration.source.entityType == Feed.self {
            let request = FetchDescriptor<Feed>(
                predicate: #Predicate<Feed> { $0.id?.uuidString == sourceID }
            )
            feed = try? moc.fetch(request).first
        }

        // Get items

        let readPredicate = #Predicate<Item> { $0.read == false }
        let extraPredicate = #Predicate<Item> { $0.extra == false }
        var predicates: [Predicate<Item>] = [readPredicate, extraPredicate]

        if let feed = feed {
            if let feedDataID = feed.feedData?.persistentModelID {
                let feedScopePredicate = #Predicate<Item> { $0.feedData?.persistentModelID == feedDataID }
                predicates.append(feedScopePredicate)
            }
        } else if let page = page {
            var pagePredicates: [Predicate<Item>] = []
            let feedDataIDs = page.feedsArray.compactMap { $0.feedData?.persistentModelID }

            if feedDataIDs.isEmpty {
                let fakeUUID = UUID()
                let emptyPredicate = #Predicate<Item> { $0.id == fakeUUID }
                predicates.append(emptyPredicate)
            } else {
                for feedDataID in feedDataIDs {
                    let pagePredicate = #Predicate<Item> { $0.feedData?.persistentModelID == feedDataID }
                    pagePredicates.append(pagePredicate)
                }
                let pagePredicate = pagePredicates.disjunction()
                predicates.append(pagePredicate)
            }
        }

        let request = FetchDescriptor<Item>(
            predicate: predicates.conjunction(),
            sortBy: [SortDescriptor(\Item.published, order: .reverse)]
        )
        
        var maxItems = 1
        if context.family == .systemLarge {
            maxItems = 4
        } else if context.family == .systemExtraLarge {
            maxItems = 8
        }
        
        if let items = try? moc.fetch(request) {
            var entryItems: [Entry.WidgetItem] = []

            for item in items.prefix(maxItems) {
                guard let id = item.id else { continue }

                entryItems.append(.init(
                    id: id,
                    itemTitle: item.title ?? "Untitled",
                    feedTitle: item.feedData?.feed?.wrappedTitle ?? "Untitled",
                    faviconURL: item.feedData?.favicon,
                    faviconImage: nil,
                    thumbnailURL: item.image,
                    thumbnailImage: nil
                ))
            }

            let entry = LatestItemsEntry(
                date: .now,
                items: entryItems,
                sourceID: page?.id ?? feed?.id,
                sourceType: {
                    if page != nil {
                        return Page.self
                    } else if feed != nil {
                        return Feed.self
                    } else {
                        return nil
                    }
                }(),
                unread: items.count,
                title: feed?.displayTitle ?? page?.displayName ?? Text(
                    "Inbox",
                    comment: "Widget title."
                ),
                faviconURL: {
                    if feed != nil {
                        return feed?.feedData?.favicon
                    } else {
                        return nil
                    }
                }(),
                faviconImage: nil,
                symbol: page?.wrappedSymbol,
                configuration: configuration
            )
            entries.append(entry)
        }

        await populateEntryImages(&entries[0])

        return Timeline(entries: entries, policy: .never)
    }
    // swiftlint:enable cyclomatic_complexity function_body_length

    private func populateEntryImages(_ entry: inout LatestItemsEntry) async {

        if let faviconURL = entry.faviconURL {
            let (faviconImage, _) = await SDWebImageManager.shared.loadImage(
                with: faviconURL,
                context: [.imageThumbnailPixelSize: CGSize(width: 96, height: 96)]
            )
            entry.faviconImage = faviconImage
        }

        for (idx, item) in entry.items.enumerated() {
            if let faviconURL = item.faviconURL {
                let (faviconImage, _) = await SDWebImageManager.shared.loadImage(
                    with: faviconURL,
                    context: [.imageThumbnailPixelSize: CGSize(width: 96, height: 96)]
                )
                entry.items[idx].faviconImage = faviconImage
            }

            if let thumbnailURL = item.thumbnailURL {
                let (thumbnailImage, _) = await SDWebImageManager.shared.loadImage(
                    with: thumbnailURL,
                    context: [.imageThumbnailPixelSize: CGSize(width: 240, height: 240)]
                )
                entry.items[idx].thumbnailImage = thumbnailImage
            }
        }
    }
}
