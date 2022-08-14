//
//  ShowcaseSectionView.swift
//  Den
//
//  Created by Garrett Johnson on 11/28/21.
//  Copyright © 2021 Garrett Johnson. All rights reserved.
//

import SwiftUI

struct ShowcaseSectionView: View {
    @ObservedObject var feed: Feed
    @Binding var hideRead: Bool
    @Binding var refreshing: Bool
    var width: CGFloat

    var body: some View {
        Section(header: header.modifier(PinnedSectionHeaderModifier())) {
            if feed.hasContent {
                if visibleItems.isEmpty {
                    Label("No unread items", systemImage: "checkmark")
                        .imageScale(.small)
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(12)
                        .background(Color(UIColor.secondarySystemGroupedBackground))
                        .cornerRadius(8)
                        .padding()
                } else {
                    BoardView(
                        width: width,
                        list: visibleItems,
                        content: { item in
                            ItemActionView(item: item) {
                                ItemPreviewView(item: item).transition(.moveTopAndFade)
                            }
                            .cornerRadius(8)
                        }
                    ).padding()
                }
            } else {
                FeedUnavailableView(feedData: feed.feedData)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(12)
                    .background(Color(UIColor.secondarySystemGroupedBackground))
                    .cornerRadius(8)
                    .padding()
            }
        }
    }

    private var header: some View {
        HStack {
            if feed.id != nil {
                NavigationLink {
                    FeedView(
                        feed: feed,
                        unreadCount: feed.feedData!.previewItems.unread().count,
                        refreshing: $refreshing
                    )
                } label: {
                    HStack {
                        FeedTitleLabelView(
                            title: feed.wrappedTitle,
                            favicon: feed.feedData!.favicon
                        )
                        Spacer()
                        NavChevronView()
                    }
                    .padding(.leading, 28)
                    .padding(.trailing, 28)
                }
                .buttonStyle(
                    FeedTitleButtonStyle(backgroundColor: Color(UIColor.tertiarySystemGroupedBackground))
                )
                .accessibilityIdentifier("showcase-section-feed-button")
            }
        }
    }

    private var visibleItems: [Item] {
        feed.feedData!.previewItems.filter { item in
            hideRead ? item.read == false : true
        }
    }
}
