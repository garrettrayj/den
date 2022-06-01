//
//  BlendItemView.swift
//  Den
//
//  Created by Garrett Johnson on 1/28/22.
//  Copyright © 2022 Garrett Johnson. All rights reserved.
//

import SwiftUI

struct BlendItemView: View {
    @ObservedObject var item: Item

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            NavigationLink {
                FeedView(viewModel: FeedViewModel(
                    feed: item.feedData!.feed!,
                    refreshing: false
                ))
            } label: {
                HStack {
                    FeedTitleLabelView(
                        title: item.feedData?.feed?.wrappedTitle ?? "Untitled",
                        favicon: item.feedData?.favicon
                    )
                    Spacer()
                    NavChevronView()
                }.padding(.horizontal, 12)
            }
            .buttonStyle(FeedTitleButtonStyle())
            .accessibilityIdentifier("item-feed-button")

            Divider()

            ItemPreviewView(item: item)
        }
        .modifier(GroupBlockModifier())
        .transition(.move(edge: .top))
    }
}
