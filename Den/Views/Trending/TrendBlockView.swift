//
//  TrendBlockView.swift
//  Den
//
//  Created by Garrett Johnson on 7/2/22.
//  Copyright © 2022 Garrett Johnson. All rights reserved.
//

import SwiftUI
import NaturalLanguage

struct TrendBlockView: View {
    @ObservedObject var trend: Trend
    @Binding var refreshing: Bool

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

    var body: some View {
        VStack {
            NavigationLink(value: TrendPanel.trend(trend)) {
                VStack(alignment: .leading, spacing: 12) {
                    HStack(alignment: .top, spacing: 8) {
                        Text(trend.wrappedTitle).font(.title).lineLimit(1)
                        Spacer()
                        HStack {
                            if let symbol = symbol {
                                Image(systemName: symbol)
                                    .imageScale(.small)
                                    .foregroundColor(Color(UIColor.tertiaryLabel))
                            }
                            Text("\(trend.items.unread().count)").modifier(CapsuleModifier())
                        }
                    }

                    LazyVGrid(columns: columns, alignment: .leading, spacing: 12) {
                        ForEach(trend.feeds) { feed in
                            FeedFaviconView(url: feed.feedData?.favicon, purgeable: false)
                                .opacity(trend.items.unread().isEmpty ? UIConstants.dimmedImageOpacity : 1.0)
                        }
                    }

                    Text("""
                    \(trend.items.count) items in \(trend.feeds.count) feeds
                    """)
                        .font(.footnote)
                        .foregroundColor(.secondary)
                }
                .padding(12)
                .foregroundColor(trend.items.unread().isEmpty ? .secondary : .primary)
            }
            .buttonStyle(HoverShadowButtonStyle())
        }
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .cornerRadius(8)
    }
}
