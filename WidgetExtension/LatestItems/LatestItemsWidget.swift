//
//  LatestItemsWidget.swift
//  LatestItemsWidget
//
//  Created by Garrett Johnson on 4/28/24.
//  Copyright © 2024 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import CoreData
import WidgetKit
import SwiftUI

import SDWebImage
import SDWebImageSVGCoder
import SDWebImageWebPCoder

struct LatestItemsWidgetProvider: AppIntentTimelineProvider {
    var viewContext: NSManagedObjectContext
    
    func placeholder(in context: Context) -> LatestItemsWidgetEntry {
        LatestItemsWidgetEntry(
            date: Date(),
            items: [],
            unread: 10,
            configuration: LatestItemsConfigurationIntent(source: .allSources.first!)
        )
    }

    func snapshot(
        for configuration: LatestItemsConfigurationIntent,
        in context: Context
    ) async -> LatestItemsWidgetEntry {
        LatestItemsWidgetEntry(
            date: Date(),
            items: [],
            unread: 10,
            configuration: configuration
        )
    }
    
    func timeline(
        for configuration: LatestItemsConfigurationIntent,
        in context: Context
    ) async -> Timeline<LatestItemsWidgetEntry> {
        var entries: [LatestItemsWidgetEntry] = []
        
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
            let entry = LatestItemsWidgetEntry(
                date: .now,
                items: items.prefix(maxItems).compactMap {
                    guard let id = $0.id else { return nil }
                    
                    var faviconImage: Image?
                    dispatchGroup.enter()
                    SDWebImageManager.shared.loadImage(
                        with: $0.feedData?.favicon,
                        context: [.imageThumbnailPixelSize: CGSize(width: 32, height: 32)],
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
}

struct LatestItemsWidgetEntry: TimelineEntry {
    struct WidgetItem: Identifiable {
        var id: UUID
        var itemTitle: String
        var feedTitle: String
        var favicon: Image?
        var thumbnail: Image?
    }
    
    let date: Date
    let items: [WidgetItem]
    let unread: Int
    let configuration: LatestItemsConfigurationIntent
}

struct LatestItemsWidgetEntryView: View {
    @Environment(\.widgetFamily) private var widgetFamily
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    
    @AppStorage("ShowUnreadCounts") private var showUnreadCounts = true
    
    @ScaledMetric(relativeTo: .largeTitle) var denIconSize = 20
    @ScaledMetric(relativeTo: .title) var thumbnailSize = 64
    
    var entry: LatestItemsWidgetProvider.Entry
    
    var maxColumnItems: Int {
        if widgetFamily == .systemLarge || widgetFamily == .systemExtraLarge {
            if dynamicTypeSize > .xxxLarge {
                return 1
            } else if dynamicTypeSize > .large {
                return 2
            } else {
                return 3
            }
        }
        
        return 1
    }

    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Label {
                    Text(entry.configuration.source.title)
                } icon: {
                    if entry.configuration.source.entityType == Feed.self {
                        if let favicon = entry.configuration.source.favicon {
                            favicon
                                .resizable()
                                .scaledToFit()
                                .frame(width: 16, height: 16)
                        }
                    } else if entry.configuration.source.entityType == Page.self {
                        if let symbol = entry.configuration.source.symbol {
                            Image(systemName: symbol).imageScale(.small)
                        }
                    } else {
                        if entry.unread > 0 {
                            Image(systemName: "tray.full")
                        } else {
                            Image(systemName: "tray")
                        }
                    }
                }
                .font(.title3)
                .lineLimit(1)
                
                Spacer()
                
                if !entry.items.isEmpty && showUnreadCounts {
                    Text("\(entry.unread)")
                        .font(.footnote.weight(.medium))
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background { Capsule().fill(.fill.secondary) }
                        .padding(.horizontal, 4)
                }
                
                Image("SimpleIcon")
                    .resizable()
                    .scaledToFit()
                    .opacity(0.8)
                    .frame(width: denIconSize, height: denIconSize)
                    .offset(y: -(denIconSize / 10))
            }
            
            if entry.items.isEmpty {
                Text("No Unread Items", comment: "Widget empty message.")
                    .font(.title2)
                    .foregroundStyle(.tertiary)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if widgetFamily == .systemExtraLarge {
                HStack(alignment: .top, spacing: 16) {
                    VStack(spacing: 8) {
                        ForEach(
                            entry.items.enumerated().filter { $0.offset.isMultiple(of: 2) }.prefix(maxColumnItems),
                            id: \.element.id
                        ) { _, item in
                            Divider()
                            itemView(item: item)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .topLeading)
                    
                    VStack(spacing: 8) {
                        ForEach(
                            entry.items.enumerated().filter { !$0.offset.isMultiple(of: 2) }.prefix(maxColumnItems),
                            id: \.element.id
                        ) { _, item in
                            Divider()
                            itemView(item: item)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .topLeading)
                }
            } else {
                ForEach(entry.items.prefix(maxColumnItems)) { item in
                    Divider()
                    itemView(item: item)
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }
    
    func itemView(item: LatestItemsWidgetEntry.WidgetItem) -> some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 4) {
                if entry.configuration.source.entityType != Feed.self {
                    Label {
                        Text(item.feedTitle)
                    } icon: {
                        if let favicon = item.favicon {
                            favicon
                                .resizable()
                                .scaledToFit()
                                .frame(width: 12, height: 12)
                        } else {
                            Image(systemName: "dot.radiowaves.up.forward").imageScale(.small)
                        }
                    }
                    #if os(macOS)
                    .font(.callout)
                    #else
                    .font(.footnote)
                    #endif
                    .imageScale(.small)
                    .lineLimit(1)
                }
                Text(item.itemTitle)
                    .lineLimit(entry.configuration.source.entityType == Feed.self ? 4 : 3)
                    .fixedSize(horizontal: false, vertical: true)
                    #if os(macOS)
                    .font(.headline)
                    #else
                    .font(.body.weight(.semibold))
                    #endif
            }
            
            Spacer(minLength: 0)
            
            if let image = item.thumbnail {
                image
                    .resizable()
                    .scaledToFill()
                    .frame(width: thumbnailSize, height: thumbnailSize)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .overlay {
                        RoundedRectangle(cornerRadius: 8).strokeBorder(.separator, lineWidth: 1)
                    }
                    .padding(.leading, 8)
            }
        }
    }
}

struct LatestItemsWidget: Widget {
    let kind: String = "LatestItemsWidget"
    
    var persistentContainer = PersistenceController.shared.container
    
    init() {
        SDImageCodersManager.shared.addCoder(SDImageSVGCoder.shared)
        SDImageCodersManager.shared.addCoder(SDImageWebPCoder.shared)
    }

    var body: some WidgetConfiguration {
        AppIntentConfiguration(
            kind: kind,
            intent: LatestItemsConfigurationIntent.self,
            provider: LatestItemsWidgetProvider(viewContext: persistentContainer.viewContext)
        ) { entry in
            LatestItemsWidgetEntryView(entry: entry)
                .containerBackground(.background, for: .widget)
                .defaultAppStorage(.group)
        }
        .configurationDisplayName(
            Text("Latest Items", comment: "Widget display name.")
        )
        .description(
            Text("Shows the latest items in a feed or page.", comment: "Widget description.")
        )
        .supportedFamilies([
            .systemMedium,
            .systemLarge,
            .systemExtraLarge
        ])
    }
}

extension LatestItemsConfigurationIntent {
    fileprivate static var inbox: LatestItemsConfigurationIntent {
        let intent = LatestItemsConfigurationIntent(
            source: SourceDetail(
                id: UUID(),
                entityType: nil,
                title: "Inbox",
                symbol: "tray",
                favicon: nil
            )
        )
        
        return intent
    }
}

#Preview(as: .systemMedium) {
    LatestItemsWidget()
} timeline: {
    LatestItemsWidgetEntry(
        date: .now, 
        items: [],
        unread: 10,
        configuration: .inbox
    )
}
