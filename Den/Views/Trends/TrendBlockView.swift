//
//  TrendBlockView.swift
//  Den
//
//  Created by Garrett Johnson on 7/2/22.
//  Copyright © 2022 Garrett Johnson. All rights reserved.
//

import SwiftUI

struct TrendBlockView: View {
    @ObservedObject var trend: Trend

    let columns = [
        GridItem(.adaptive(minimum: 16, maximum: 16), spacing: 12, alignment: .top)
    ]

    var body: some View {
        VStack {
            NavigationLink {
                TrendView(trend: trend, unreadCount: trend.items.unread().count)
            } label: {
                VStack(alignment: .leading, spacing: 12) {
                    Text(trend.wrappedTitle).font(.title)
                    Text("\(trend.items.count) items in \(trend.feeds.count) feeds").font(.subheadline)
                    LazyVGrid(columns: columns, alignment: .leading, spacing: 12) {
                        ForEach(trend.feeds) { feed in
                            FeedFaviconView(url: feed.feedData?.favicon)
                                .opacity(trend.items.unread().isEmpty ? UIConstants.dimmedImageOpacity : 1.0)
                        }
                    }
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
