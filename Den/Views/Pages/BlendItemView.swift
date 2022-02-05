//
//  BlendItemView.swift
//  Den
//
//  Created by Garrett Johnson on 1/28/22.
//  Copyright © 2022 Garrett Johnson. All rights reserved.
//

import SwiftUI

struct BlendItemView: View {
    @EnvironmentObject private var refreshManager: RefreshManager

    @ObservedObject var item: Item

    var feedViewModel: FeedViewModel?

    var body: some View {
        if feedViewModel != nil {
            VStack(alignment: .leading, spacing: 0) {
                NavigationLink {
                    FeedView(viewModel: feedViewModel!)
                } label: {
                    HStack {
                        FeedTitleLabelView(
                            title: feedViewModel!.feed.wrappedTitle,
                            faviconImage: feedViewModel!.feed.feedData?.faviconImage
                        )
                        Spacer()
                        NavChevronView()
                    }.padding(.horizontal, 12)
                }
                .buttonStyle(FeedTitleButtonStyle())
                .disabled(refreshManager.isRefreshing)
                .accessibilityIdentifier("item-feed-button")

                Divider()

                ItemPreviewView(item: item)
            }
            .modifier(GroupBlockModifier())
        }
    }
}
