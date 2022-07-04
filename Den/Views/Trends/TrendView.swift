//
//  TrendView.swift
//  Den
//
//  Created by Garrett Johnson on 7/2/22.
//  Copyright © 2022 Garrett Johnson. All rights reserved.
//

import SwiftUI

struct TrendView: View {
    var trend: Trend

    let columns = [
        GridItem(.adaptive(minimum: 16, maximum: 16), spacing: 8, alignment: .top)
    ]

    var body: some View {
        NavigationLink {
            TrendDetailView(trend: trend)
        } label: {
            VStack(alignment: .leading, spacing: 8) {
                Text(trend.text).font(.title).padding(.horizontal, 12)

                Text("\(trend.items.count) items in \(trend.feeds.count) feeds")
                    .padding(.horizontal, 12)

                LazyVGrid(columns: columns, spacing: 8) {
                    ForEach(trend.feeds) { feed in
                        FeedFaviconView(url: feed.feedData?.favicon)
                    }
                }.padding(.horizontal, 4)
            }
            .padding(.vertical, 12)
        }
        .fixedSize(horizontal: false, vertical: true)
        .modifier(GroupBlockModifier())
        .buttonStyle(HoverShadowButtonStyle())
    }
}
