//
//  SearchResultView.swift
//  Den
//
//  Created by Garrett Johnson on 9/6/20.
//  Copyright © 2020 Garrett Johnson. All rights reserved.
//

import SwiftUI

struct SearchResultView: View {
    var items: [Item]
    var feedData: FeedData {
        items.first!.feedData!
    }

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                FeedTitleLabelView(
                    title: feedData.feed!.wrappedTitle,
                    faviconImage: feedData.faviconImage
                )
                Spacer()
            }.frame(height: 32)

            VStack(spacing: 12) {
                ForEach(items) { item in
                    Group {
                        Divider()
                        GadgetItemView(
                            item: item,
                            feed: feedData.feed!
                        )
                    }
                }
            }
        }
        .padding([.horizontal, .bottom], 12)
        .modifier(GroupBlockModifier())
    }
}
