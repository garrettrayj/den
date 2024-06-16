//
//  LatestItemsView.swift
//  Den
//
//  Created by Garrett Johnson on 5/5/24.
//  Copyright © 2024 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI
import WidgetKit

struct LatestItemsView: View {
    @Environment(\.widgetFamily) private var widgetFamily
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    
    @AppStorage("ShowUnreadCounts") private var showUnreadCounts = true
    
    @ScaledMetric(relativeTo: .largeTitle) var smallIconSize = 20
    @ScaledMetric(relativeTo: .largeTitle) var largeIconSize = 32
    @ScaledMetric(relativeTo: .largeTitle) var thumbnailSize = 80
    
    var entry: LatestItemsProvider.Entry
    
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
        Group {
            if widgetFamily == .systemSmall {
                statusLayout
            } else {
                itemListLayout
            }
        }
        .widgetURL(entry.url())
    }
    
    private var statusLayout: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .top) {
                sourceIcon
                    .scaledToFit()
                    .frame(width: largeIconSize, height: largeIconSize)
                Spacer()
                
                if !entry.items.isEmpty && showUnreadCounts {
                    unreadCount
                }
                
                denIcon
            }
            Spacer()
            entry.title
                .font(.title)
                .foregroundStyle(entry.unread == 0 ? .secondary : .primary)
                .minimumScaleFactor(0.6)
        }
    }
    
    private var itemListLayout: some View {
        VStack(spacing: 8) {
            HStack {
                Label {
                    entry.title
                } icon: {
                    sourceIcon
                        .scaledToFit()
                        .frame(width: smallIconSize, height: smallIconSize)
                }
                .font(.title3)
                .lineLimit(1)
                
                Spacer()
                
                if !entry.items.isEmpty && showUnreadCounts {
                    unreadCount
                }
                
                denIcon
            }
            
            if entry.items.isEmpty {
                Text("No Unread Items", comment: "Widget empty message.")
                    .font(.title2)
                    .foregroundStyle(.tertiary)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if widgetFamily == .systemExtraLarge {
                doubleColumnView
            } else {
                singleColumnView
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }
    
    private var denIcon: some View {
        Rectangle()
            .fill(.secondary)
            .mask(alignment: .center) {
                Image("SimpleIcon").resizable().scaledToFit()
            }
            .frame(width: smallIconSize, height: smallIconSize)
            .offset(y: -1)
    }
    
    private var unreadCount: some View {
        Text(verbatim: "\(entry.unread)")
            .font(.footnote.weight(.medium).monospacedDigit())
            .foregroundStyle(.secondary)
            .padding(.horizontal, 8)
            .padding(.vertical, 2)
            .background { Capsule().fill(.fill.secondary) }
    }
    
    @ViewBuilder
    private var sourceIcon: some View {
        if entry.sourceType == Feed.self {
            if let favicon = entry.faviconImage {
                favicon.resizable().clipShape(RoundedRectangle(
                    cornerRadius: widgetFamily == .systemSmall ? 4 : 2
                ))
            } else {
                Image(systemName: "dot.radiowaves.up.forward").resizable()
            }
        } else if entry.sourceType == Page.self {
            if let symbol = entry.symbol {
                Image(systemName: symbol).resizable()
            }
        } else if entry.unread > 0 {
            Image(systemName: "tray.full").resizable()
        } else {
            Image(systemName: "tray").resizable()
        }
    }
    
    private var singleColumnView: some View {
        ForEach(entry.items.prefix(maxColumnItems)) { item in
            Divider()
            itemView(item: item)
        }
    }
    
    private var doubleColumnView: some View {
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
    }
    
    private func itemView(item: LatestItemsEntry.WidgetItem) -> some View {
        Link(destination: entry.url(item: item)) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    if entry.configuration.source.entityType != Feed.self {
                        Label {
                            Text(item.feedTitle)
                        } icon: {
                            if let favicon = item.faviconImage {
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
                
                if let image = item.thumbnailImage {
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
            .frame(height: thumbnailSize, alignment: .top)
        }
    }
}
