//
//  TrendBlockView.swift
//  Den
//
//  Created by Garrett Johnson on 7/2/22.
//  Copyright © 2022 Garrett Johnson. All rights reserved.
//

import SwiftUI

struct TrendBlockView: View {
    var trend: Trend

    let columns = [
        GridItem(.adaptive(minimum: 16, maximum: 16), spacing: 8, alignment: .top)
    ]

    var body: some View {
        VStack {
            NavigationLink {
                TrendItemsView(trend: trend)
            } label: {
                VStack(alignment: .leading, spacing: 8) {
                    Text(trend.wrappedTitle).font(.title)

                    Text("\(trend.items.count) items in \(trend.feeds.count) feeds").font(.subheadline)

                    LazyVGrid(columns: columns, alignment: .leading, spacing: 8) {
                        ForEach(trend.feeds) { feed in
                            FeedFaviconView(url: feed.feedData?.favicon)
                        }
                    }
                }
                .padding(12)
            }
            .buttonStyle(HoverShadowButtonStyle())
        }
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .cornerRadius(8)
    }
}
