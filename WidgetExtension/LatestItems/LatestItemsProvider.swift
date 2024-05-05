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
            unread: 10,
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
            unread: 10,
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
        
        let dispatchGroup = DispatchGroup()
        
        if let items = try? viewContext.fetch(request) {
            let entry = LatestItemsEntry(
                date: .now,
                items: items.prefix(maxItems).compactMap {
                    guard let id = $0.id else { return nil }
                    
                    var faviconImage: Image?
                    dispatchGroup.enter()
                    SDWebImageManager.shared.loadImage(
                        with: $0.feedData?.favicon,
                        context: [.imageThumbnailPixelSize: CGSize(width: 96, height: 96)],
                        progress: nil
                    ) { image, _, _, _, _, _ in
                        if let image = image {
                            #if os(macOS)
                            faviconImage = Image(nsImage: image)
                            #else
                            faviconImage = Image(uiImage: image)
                            #endif
                        }
                        dispatchGroup.leave()
                    }
                    dispatchGroup.wait()
                    
                    var thumbnailImage: Image?
                    dispatchGroup.enter()
                    SDWebImageManager.shared.loadImage(
                        with: $0.image,
                        context: [.imageThumbnailPixelSize: CGSize(width: 192, height: 192)],
                        progress: nil
                    ) { image, _, _, _, _, _ in
                        if let image = image {
                            #if os(macOS)
                            thumbnailImage = Image(nsImage: image)
                            #else
                            thumbnailImage = Image(uiImage: image)
                            #endif
                        }
                        dispatchGroup.leave()
                    }
                    dispatchGroup.wait()
                    
                    return .init(
                        id: id,
                        itemTitle: $0.title ?? "Untitled",
                        feedTitle: $0.feedData?.feed?.wrappedTitle ?? "Untitled",
                        favicon: faviconImage,
                        thumbnail: thumbnailImage
                    )
                },
                unread: items.count,
                configuration: configuration
            )
            entries.append(entry)
        }

        return Timeline(entries: entries, policy: .never)
    }
    // swiftlint:enable cyclomatic_complexity function_body_length
}
