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

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            NavigationLink(value: FeedPanel.feed(item.feedData?.feed)) {
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
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .cornerRadius(8)
    }
}
