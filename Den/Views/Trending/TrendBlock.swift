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
            NavigationLink(value: SubDetailPanel.trend(trend)) {
                VStack(alignment: .leading, spacing: 12) {
                    trend.titleText.font(.title).lineLimit(1)

                    LazyVGrid(columns: columns, alignment: .leading, spacing: 12) {
                        ForEach(uniqueFaviconURLs, id: \.self) { url in
                            FeedFavicon(url: url)
                        }
                    }.opacity(trend.hasUnread ? 1.0 : 0.5)

                    HStack {
                        if let symbol = symbol {
                            Image(systemName: symbol).imageScale(.small)
                        }
                        Text("""
                        \(trend.items.count) items in \(trend.feeds.count) feeds. \
                        \(trend.items.unread().count) unread
                        """, comment: "Trend block status message.")
                    }
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                }
                .padding(12)
                .foregroundStyle(trend.items.unread().isEmpty ? .secondary : .primary)
            }
            .buttonStyle(HoverShadowButtonStyle())
        }
        .modifier(RoundedContainerModifier())
    }
}
