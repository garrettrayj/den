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
import CoreData
import WidgetKit
import SwiftUI

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
        
        let moc = WidgetDataController.getContainer().newBackgroundContext()
        
        moc.performAndWait {
            var feed: Feed?
            var page: Page?
            
            // Fetch scope object
            if configuration.source.entityType == Page.self {
                let request = Page.fetchRequest()
                request.predicate = NSPredicate(
                    format: "id = %@",
                    configuration.source.id
                )
                page = try? moc.fetch(request).first
            } else if configuration.source.entityType == Feed.self {
                let request = Feed.fetchRequest()
                request.predicate = NSPredicate(
                    format: "id = %@",
                    configuration.source.id
                )
                feed = try? moc.fetch(request).first
            }
            
            // Get items
            var predicates: [NSPredicate] = [
                NSPredicate(format: "read = %@", NSNumber(value: false)),
                NSPredicate(format: "extra = %@", NSNumber(value: false))
            ]
            
            if let feed = feed {
                if let feedData = feed.feedData {
                    predicates.append(
                        NSPredicate(format: "feedData = %@", feedData)
                    )
                }
            } else if let page = page {
                predicates.append(NSPredicate(
                    format: "feedData IN %@",
                    page.feedsArray.compactMap { $0.feedData }
                ))
            }
            
            let request = Item.fetchRequest()
            request.predicate = NSCompoundPredicate(type: .and, subpredicates: predicates)
            request.sortDescriptors = [NSSortDescriptor(keyPath: \Item.published, ascending: false)]
            
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
