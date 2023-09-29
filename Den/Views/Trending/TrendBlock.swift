//
//  TrendBlock.swift
//  Den
//
//  Created by Garrett Johnson on 7/2/22.
//  Copyright © 2022 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import NaturalLanguage
import SwiftUI

struct TrendBlock: View {
    @ObservedObject var trend: Trend

    var symbol: String? {
        if trend.tag == NLTag.personalName.rawValue {
            return "person"
        } else if trend.tag == NLTag.organizationName.rawValue {
            return "building"
        } else if trend.tag == NLTag.placeName.rawValue {
            return "mappin.and.ellipse"
        }
        return nil
    }

    var uniqueFaviconURLs: [URL] {
        trend.feeds.compactMap { feed in
            feed.feedData?.favicon
        }.uniqueElements()
    }

    var body: some View {
        NavigationLink(value: SubDetailPanel.trend(trend)) {
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    trend.titleText.font(.title2.weight(.medium))

                    Grid {
                        ForEach(uniqueFaviconURLs.chunked(by: 10), id: \.self) { favicons in
                            GridRow {
                                ForEach(favicons, id: \.self) { favicon in
                                    FeedFavicon(url: favicon)
                                }
                            }
                        }
                    }
                    .opacity(trend.hasUnread ? 1.0 : 0.5)

                    HStack {
                        if let symbol = symbol {
                            Image(systemName: symbol).imageScale(.small)
                        }
                        Text("""
                        \(trend.items.count) items in \(trend.feeds.count) feeds. \
                        \(trend.items.unread().count) unread
                        """, comment: "Trend status line.")
                    }
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                }
                .foregroundStyle(trend.items.unread().isEmpty ? .secondary : .primary)
                Spacer(minLength: 0)
            }
            .padding()
        }
        .buttonStyle(BasicHoverButtonStyle())
    }
}
