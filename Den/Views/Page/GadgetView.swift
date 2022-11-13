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
                    ForEach(visibleItems) { item in
                        GadgetItemView(item: item)
                    }

                    if hideRead == true && feed.feedData!.previewItems.unread().isEmpty {
                        Divider()
                        AllReadCompactView()
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
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .cornerRadius(8)
    }

    private var header: some View {
        HStack {
            NavigationLink(value: DetailPanel.feed(feed)) {
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

    private var visibleItems: [Item] {
        feed.feedData!.previewItems.filter { item in
            hideRead ? item.read == false : true
        }
    }
}
