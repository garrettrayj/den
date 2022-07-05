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
    @Binding var hideRead: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            header

            VStack(spacing: 0) {
                if feed.hasContent {
                    if hideRead == true && feed.feedData!.previewItems.unread().isEmpty {
                        Divider()
                        Label("No unread items", systemImage: "checkmark")
                            .imageScale(.small)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .foregroundColor(.secondary)
                            .padding(12)
                    } else {
                        ForEach(feed.feedData!.previewItems) { item in
                            GadgetItemView(item: item, feed: feed, hideRead: $hideRead)
                        }
                    }
                } else {
                    Divider()
                    FeedUnavailableView(feedData: feed.feedData)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                }
            }
            .clipped()
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
