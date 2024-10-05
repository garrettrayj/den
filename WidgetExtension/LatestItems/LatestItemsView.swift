//
//  LatestItemsView.swift
//  Den
//
//  Created by Garrett Johnson on 5/5/24.
//  Copyright © 2024 Garrett Johnson. All rights reserved.
//

import SwiftUI
import WidgetKit

// swiftlint:disable type_body_length
struct LatestItemsView: View {
    @Environment(\.widgetFamily) private var widgetFamily
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @Environment(\.widgetRenderingMode) var widgetRenderingMode
    
    @AppStorage("ShowUnreadCounts") private var showUnreadCounts = true
    @AppStorage("AccentColor") private var accentColor: AccentColorOption = .coral
    
    @ScaledMetric(relativeTo: .largeTitle) var smallIconSize = 16
    @ScaledMetric(relativeTo: .largeTitle) var largeIconSize = 32
    
    @ScaledMetric(relativeTo: .footnote) var unreadCountFontSize = 12
    @ScaledMetric(relativeTo: .title) var widgetTitleFontSize = 15
    @ScaledMetric(relativeTo: .headline) var itemTitleFontSize = 14
    @ScaledMetric(relativeTo: .caption) var itemSourceFontSize = 10
    
    var entry: LatestItemsProvider.Entry
    
    var maxColumnItems: Int {
        if widgetFamily == .systemLarge || widgetFamily == .systemExtraLarge {
            if dynamicTypeSize > .accessibility1 {
                return 1
            } else if dynamicTypeSize > .xxxLarge {
                return 2
            } else if dynamicTypeSize > .large {
                return 3
            } else {
                return 4
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
        .tint(accentColor.color)
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
                    entry.title.font(.system(size: widgetTitleFontSize, weight: .bold))
                } icon: {
                    sourceIcon
                        .scaledToFit()
                        .frame(width: smallIconSize, height: smallIconSize)
                        .foregroundStyle(accentColor.color ?? .accentColor)
                }
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
        Group {
            if #available(iOS 18.0, macOS 15.0, *) {
                if widgetRenderingMode == .fullColor {
                    Rectangle()
                        .fill(.tint)
                        .mask(alignment: .center) {
                            Image("WidgetIcon").resizable().scaledToFit()
                        }
                } else {
                    Image("WidgetIcon").resizable().widgetAccentedRenderingMode(.accentedDesaturated)
                }
            } else {
                Rectangle()
                    .fill(.tint)
                    .mask(alignment: .center) {
                        Image("WidgetIcon").resizable().scaledToFit()
                    }
            }
        }
        .frame(width: smallIconSize, height: smallIconSize)
        .offset(y: -2)
    }
    
    private var unreadCount: some View {
        Text(verbatim: "\(entry.unread)")
            .font(.system(size: unreadCountFontSize, weight: .medium))
            .foregroundStyle(.secondary)
    }
    
    @ViewBuilder
    private var sourceIcon: some View {
        if #available(iOS 18.0, macOS 15.0, *) {
            if entry.sourceType == Feed.self {
                if let favicon = entry.faviconImage {
                    favicon
                        .resizable()
                        .widgetAccentedRenderingMode(.fullColor)
                        .clipShape(
                            RoundedRectangle(cornerRadius: widgetFamily == .systemSmall ? 4 : 2)
                        )
                } else {
                    Image(systemName: "dot.radiowaves.up.forward")
                        .resizable()
                        .widgetAccentedRenderingMode(.accented)
                }
            } else if entry.sourceType == Page.self {
                if let symbol = entry.symbol {
                    Image(systemName: symbol).resizable().widgetAccentedRenderingMode(.accented)
                }
            } else if entry.unread > 0 {
                Image(systemName: "tray.full").resizable().widgetAccentedRenderingMode(.accented)
            } else {
                Image(systemName: "tray").resizable().widgetAccentedRenderingMode(.accented)
            }
        } else {
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
    }
    
    private var singleColumnView: some View {
        VStack(spacing: 12) {
            ForEach(entry.items.prefix(maxColumnItems)) { item in
                itemView(item: item)
            }
        }
    }
    
    private var doubleColumnView: some View {
        var firstColumnItems: [LatestItemsEntry.WidgetItem] = []
        var secondColumnItems: [LatestItemsEntry.WidgetItem] = []
        
        for (offset, item) in entry.items.enumerated() {
            if offset.isMultiple(of: 2) {
                firstColumnItems.append(item)
            } else {
                secondColumnItems.append(item)
            }
        }
        
        return HStack(alignment: .top, spacing: 16) {
            VStack(spacing: 12) {
                ForEach(0..<maxColumnItems, id: \.self) { idx in
                    if firstColumnItems.indices.contains(idx) {
                        itemView(item: firstColumnItems[idx])
                    } else {
                        ZStack {}.frame(maxHeight: .infinity)
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .topLeading)
            
            VStack(spacing: 12) {
                ForEach(0..<maxColumnItems, id: \.self) { idx in
                    if secondColumnItems.indices.contains(idx) {
                        itemView(item: secondColumnItems[idx])
                    } else {
                        ZStack {}.frame(maxHeight: .infinity)
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .topLeading)
        }
    }
    
    private func itemView(item: LatestItemsEntry.WidgetItem) -> some View {
        Link(destination: entry.url(item: item)) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 1) {
                    if entry.configuration.source?.entityType != Feed.self {
                        HStack(spacing: 4) {
                            if let favicon = item.faviconImage {
                                Group {
                                    if #available(iOS 18, macOS 15.0, *) {
                                        favicon
                                            .resizable()
                                            .widgetAccentedRenderingMode(.fullColor)
                                    } else {
                                        favicon.resizable()
                                    }
                                }
                                .scaledToFit()
                                .grayscale(1)
                                .opacity(0.5)
                                .frame(width: itemSourceFontSize, height: itemSourceFontSize)
                            } else {
                                Image(systemName: "dot.radiowaves.up.forward").imageScale(.small)
                            }
                            
                            Text(item.feedTitle)
                        }
                        .font(.system(size: itemSourceFontSize, weight: .medium))
                        .imageScale(.small)
                        .lineLimit(1)
                        .foregroundStyle(.secondary)
                    }
                    Text(item.itemTitle)
                        .lineLimit(widgetFamily == .systemMedium ? 6 : 3)
                        .font(
                            .system(size: itemTitleFontSize, weight: .bold)
                            .leading(.tight)
                        )
                        .padding(.bottom, -4)
                }
                
                Spacer(minLength: 0)
                
                if let image = item.thumbnailImage {
                    itemThumbnail(image: image)
                } else {
                    ZStack {}
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .aspectRatio(1, contentMode: .fit)
                        .padding(.leading, 8)
                }
            }
            .frame(maxHeight: .infinity, alignment: .top)
        }
    }
    
    private func itemThumbnail(image: Image) -> some View {
        ZStack {
            GeometryReader { geometry in
                Group {
                    if #available(iOS 18.0, macOS 15.0, *) {
                        image
                            .resizable()
                            .widgetAccentedRenderingMode(.fullColor)
                    } else {
                        image.resizable()
                    }
                }
                .scaledToFill()
                .frame(width: geometry.size.width, height: geometry.size.height)
                .overlay {
                    RoundedRectangle(cornerRadius: 8).strokeBorder(.separator.quinary, lineWidth: 1)
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .aspectRatio(1, contentMode: .fit)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .padding(.leading, 8)
    }
}
// swiftlint:enable type_body_length
