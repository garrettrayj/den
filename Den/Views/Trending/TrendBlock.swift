//
//  TrendBlock.swift
//  Den
//
//  Created by Garrett Johnson on 7/2/22.
//  Copyright © 2022 Garrett Johnson
//

import NaturalLanguage
import SwiftUI

import SDWebImageSwiftUI

struct TrendBlock: View {
    @Environment(\.isEnabled) private var isEnabled

    @ObservedObject var profile: Profile // Profile observed for updates
    @ObservedObject var trend: Trend

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

    private var uniqueFaviconSources: [Feed] {
        trend.feeds.compactMap { feed in
            guard let feedData = feed.feedData, feedData.favicon != nil else { return nil }
            return feed
        }.uniqueElements()
    }

    var body: some View {
        NavigationLink(value: SubDetailPanel.trend(trend)) {
            VStack(alignment: .leading, spacing: 8) {
                trend.titleText.font(.title2.weight(.medium))

                Grid {
                    ForEach(uniqueFaviconSources.chunked(by: 9), id: \.self) { feeds in
                        GridRow {
                            ForEach(feeds, id: \.self) { feed in
                                FeedFavicon(feed: feed)
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
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(12)
        }
        .buttonStyle(BasicHoverButtonStyle())
    }
}
