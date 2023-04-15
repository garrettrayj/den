//
//  TrendBlock.swift
//  Den
//
//  Created by Garrett Johnson on 7/2/22.
//  Copyright © 2022 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI
import NaturalLanguage

struct TrendBlock: View {
    @ObservedObject var trend: Trend

    let columns = [
        GridItem(.adaptive(minimum: 16, maximum: 16), spacing: 12, alignment: .top)
    ]

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
        VStack {
            NavigationLink(value: DetailPanel.trend(trend)) {
                VStack(alignment: .leading, spacing: 12) {
                    HStack(alignment: .top, spacing: 8) {
                        Text(trend.wrappedTitle).font(.title).lineLimit(1)
                        Spacer()
                        HStack {
                            if let symbol = symbol {
                                Image(systemName: symbol)
                                    .imageScale(.small)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }

                    LazyVGrid(columns: columns, alignment: .leading, spacing: 12) {
                        ForEach(uniqueFaviconURLs, id: \.self) { url in
                            FeedFavicon(url: url)
                        }
                    }.opacity(trend.hasUnread ? 1.0 : AppDefaults.dimmedImageOpacity)

                    if trend.hasUnread {
                        Text("""
                        \(trend.items.count) items in \(trend.feeds.count) feeds, \
                        \(trend.items.unread().count) unread
                        """)
                            .font(.footnote)
                            .foregroundColor(.secondary)
                    } else {
                        Text("\(trend.items.count) items in \(trend.feeds.count) feeds")
                            .font(.footnote)
                            .foregroundColor(.secondary)
                    }
                }
                .padding(12)
                .foregroundColor(trend.items.unread().isEmpty ? .secondary : .primary)
            }
            .buttonStyle(HoverShadowButtonStyle())
        }
        .modifier(RoundedContainerModifier())
    }
}
