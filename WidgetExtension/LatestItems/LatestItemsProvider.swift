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
    var viewContext: NSManagedObjectContext
    
    func placeholder(in context: Context) -> LatestItemsEntry {
        LatestItemsEntry(
            date: Date(),
            items: [], 
            sourceID: nil,
            sourceType: nil,
            unread: 10,
            title: Text("Inbox"),
            favicon: nil,
            symbol: "tray",
            configuration: LatestItemsConfigurationIntent(source: .allSources.first!)
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
            title: Text("Inbox"),
            favicon: nil,
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
        
        var feed: Feed?
        var page: Page?
        
        // Fetch scope object
        if configuration.source.entityType == Page.self {
            let request = Page.fetchRequest()
            request.predicate = NSPredicate(
                format: "id = %@",
                configuration.source.id.uuidString
            )
            page = try? viewContext.fetch(request).first
        } else if configuration.source.entityType == Feed.self {
            let request = Feed.fetchRequest()
            request.predicate = NSPredicate(
                format: "id = %@",
                configuration.source.id.uuidString
            )
            feed = try? viewContext.fetch(request).first
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
            maxItems = 3
        } else if context.family == .systemExtraLarge {
            maxItems = 6
        }
        
        let (feedFaviconImage, _) = await SDWebImageManager.shared.loadImage(
            with: feed?.feedData?.favicon,
            context: [.imageThumbnailPixelSize: CGSize(width: 96, height: 96)]
        )
        
        if let items = try? viewContext.fetch(request) {
            var entryItems: [Entry.WidgetItem] = []

            for item in items.prefix(maxItems) {
                guard let id = item.id else { continue }
                
                let (faviconImage, _) = await SDWebImageManager.shared.loadImage(
                    with: item.feedData?.favicon,
                    context: [.imageThumbnailPixelSize: CGSize(width: 96, height: 96)]
                )
                
                let (thumbnailImage, _) = await SDWebImageManager.shared.loadImage(
                    with: item.image,
                    context: [.imageThumbnailPixelSize: CGSize(width: 192, height: 192)]
                )
                
                entryItems.append(.init(
                    id: id,
                    itemTitle: item.title ?? "Untitled",
                    feedTitle: item.feedData?.feed?.wrappedTitle ?? "Untitled",
                    favicon: faviconImage,
                    thumbnail: thumbnailImage
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
                title: feed?.displayTitle ?? page?.displayName ?? Text("Inbox"),
                favicon: feedFaviconImage,
                symbol: page?.wrappedSymbol,
                configuration: configuration
            )
            entries.append(entry)
        }

        return Timeline(entries: entries, policy: .never)
    }
    // swiftlint:enable cyclomatic_complexity function_body_length
}
