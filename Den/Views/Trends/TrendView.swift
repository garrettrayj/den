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
        GridItem(.adaptive(minimum: 16, maximum: 16), spacing: 6, alignment: .top)
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            NavigationLink {
                TrendDetailView(trend: trend)
            } label: {
                Text(trend.text).font(.title)
            }
            .buttonStyle(PlainButtonStyle())
            .padding(.horizontal, 12)

            Text("\(trend.items.count) items in \(trend.feeds.count) feeds")
                .padding(.horizontal, 12)

            LazyVGrid(columns: columns, alignment: .center, spacing: 8) {
                ForEach(trend.feeds) { feed in
                    FeedFaviconView(url: feed.feedData?.favicon)
                }
            }.padding(.horizontal, 8)
        }
        .padding(.vertical, 12)
        .fixedSize(horizontal: false, vertical: true)
        .modifier(GroupBlockModifier())
    }
}
