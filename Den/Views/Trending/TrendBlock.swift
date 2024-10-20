//
//  TrendBlock.swift
//  Den
//
//  Created by Garrett Johnson on 7/2/22.
//  Copyright © 2022 Garrett Johnson. All rights reserved.
//

import NaturalLanguage
import SwiftUI

import SDWebImageSwiftUI

struct TrendBlock: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    @ObservedObject var trend: Trend
    
    @ScaledMetric var gridSize = 20

    private var symbol: String? {
        if trend.tag == NLTag.personalName.rawValue {
            return "person"
        } else if trend.tag == NLTag.organizationName.rawValue {
            return "building"
        } else if trend.tag == NLTag.placeName.rawValue {
            return "mappin.and.ellipse"
        }
        return nil
    }
    
    private var favicons: [URL] {
        trend.feeds.compactMap { $0.feedData?.favicon }.uniqueElements()
    }

    var body: some View {
        NavigationLink(value: SubDetailPanel.trend(trend.objectID.uriRepresentation())) {
            VStack(alignment: .leading, spacing: 8) {
                trend.titleText.font(.title2)

                if !favicons.isEmpty {
                    Grid {
                        ForEach(favicons.chunked(by: 10), id: \.self) { chunked in
                            GridRow {
                                ForEach(chunked, id: \.self) { favicon in
                                    Favicon(url: favicon) {
                                        FeedFaviconPlaceholder()
                                    }
                                }
                            }
                        }
                    }
                    .opacity(!trend.read ? 1.0 : 0.5)
                }

                HStack {
                    if let symbol = symbol {
                        Image(systemName: symbol).imageScale(.small)
                    }
                    Text(
                        """
                        \(trend.items.count) items in \(trend.feeds.count) feeds. \
                        \(trend.items.unread.count) unread
                        """,
                        comment: "Trend status line."
                    )
                    Spacer(minLength: 0)
                }
                .font(.footnote)
                .foregroundStyle(.secondary)
            }
            .foregroundStyle(trend.read ? .secondary : .primary)
            .padding(12)
            .drawingGroup()
        }
        .buttonStyle(ContentBlockButtonStyle())
        .contextMenu {
            MarkAllReadUnreadButton(allRead: trend.items.unread.isEmpty) {
                HistoryUtility.toggleRead(items: trend.items, context: viewContext)
            }
        }
    }
}
