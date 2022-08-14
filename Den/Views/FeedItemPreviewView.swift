//
//  FeedItemPreviewView.swift
//  Den
//
//  Created by Garrett Johnson on 1/28/22.
//  Copyright © 2022 Garrett Johnson. All rights reserved.
//

import SwiftUI

struct FeedItemPreviewView: View {
    @ObservedObject var item: Item
    @Binding var refreshing: Bool

    var body: some View {
        if item.feedData?.feed != nil {
            VStack(alignment: .leading, spacing: 0) {
                NavigationLink {
                    FeedView(
                        feed: item.feedData!.feed!,
                        unreadCount: item.feedData!.previewItems.unread().count,
                        refreshing: $refreshing
                    )
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

                ItemActionView(item: item) {
                    ItemPreviewView(item: item)
                }
            }
            .modifier(GroupBlockModifier())
            .cornerRadius(8)
            .transition(.moveTopAndFade)
        }
    }
}
