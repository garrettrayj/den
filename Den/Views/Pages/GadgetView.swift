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
    @EnvironmentObject var profileManager: ProfileManager

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            header

            if feed.hasContent {
                if visibleItems.isEmpty {
                    Divider()
                    Label("No unread items", systemImage: "checkmark")
                        .foregroundColor(.secondary)
                        .padding(12)
                } else {
                    ForEach(visibleItems) { item in
                        GadgetItemView(item: item, feed: feed)
                    }
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

    private var visibleItems: [Item] {
        feed.feedData!.limitedItemsArray.filter { item in
            profileManager.activeProfile?.hideReadItems == true ? item.read == false : true
        }
    }
}
