//
//  GadgetView.swift
//  Den
//
//  Created by Garrett Johnson on 5/18/20.
//  Copyright © 2020 Garrett Johnson. All rights reserved.
//

import SwiftUI

struct GadgetView: View {
    @ObservedObject var feed: Feed

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            header

            if feed.feedData != nil && !feed.feedData!.itemsArray.isEmpty {
                ForEach(feed.feedData!.limitedItemsArray) { item in
                    Divider()
                    GadgetItemView(item: item, feed: feed)
                        .accessibilityElement(children: .combine)
                }
            } else {
                Divider()
                FeedUnavailableView(feedData: feed.feedData).padding()
            }
        }
        .fixedSize(horizontal: false, vertical: true)
        .modifier(GroupBlockModifier())
    }

    private var header: some View {
        HStack {
            if feed.id != nil {
                NavigationLink {
                    FeedView(viewModel: FeedViewModel(
                        feed: feed,
                        refreshing: false
                    ))
                } label: {
                    HStack {
                        FeedTitleLabelView(
                            title: feed.wrappedTitle,
                            favicon: feed.feedData?.favicon
                        )
                        Spacer()
                        NavChevronView()
                    }.padding(.horizontal, 12)
                }
                .buttonStyle(FeedTitleButtonStyle())
                .accessibilityIdentifier("gadget-feed-button")
            }
        }
    }
}
