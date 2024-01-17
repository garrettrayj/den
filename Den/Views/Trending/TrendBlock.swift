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
    @ObservedObject var profile: Profile // Profile observed for updates
    @ObservedObject var trend: Trend
    
    let items: [Item]
    let feeds: [Feed]

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

    var body: some View {
        NavigationLink(value: SubDetailPanel.trend(trend)) {
            VStack(alignment: .leading, spacing: 8) {
                trend.titleText.font(.title2.weight(.medium))

                Grid {
                    ForEach(feeds.chunked(by: 9), id: \.self) { feeds in
                        GridRow {
                            ForEach(feeds, id: \.self) { feed in
                                FeedFavicon(feed: feed)
                            }
                        }
                    }
                }
                .opacity(!items.unread().isEmpty ? 1.0 : 0.5)

                HStack {
                    if let symbol = symbol {
                        Image(systemName: symbol).imageScale(.small)
                    }
                    Text("""
                    \(items.count) items in \(trend.feeds.count) feeds. \
                    \(items.unread().count) unread
                    """, comment: "Trend status line.")
                }
                .font(.footnote)
                .foregroundStyle(.secondary)
            }
            .foregroundStyle(items.unread().isEmpty ? .secondary : .primary)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(12)
        }
        .buttonStyle(BasicHoverButtonStyle())
    }
}
