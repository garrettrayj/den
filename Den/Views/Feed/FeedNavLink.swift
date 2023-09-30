//
//  FeedNavLink.swift
//  Den
//
//  Created by Garrett Johnson on 6/19/23.
//  Copyright © 2023 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

struct FeedNavLink: View {
    @ObservedObject var feed: Feed

    var body: some View {
        VStack(spacing: 0) {
            NavigationLink(value: SubDetailPanel.feed(feed)) {
                HStack {
                    FeedTitleLabel(title: feed.titleText, favicon: feed.feedData?.favicon)
                        .modifier(DraggableFeedModifier(feed: feed))
                    Spacer()
                    ButtonChevron()
                }
            }
            .accessibilityIdentifier("FeedNavLink")
            BackedDivider()
        }
    }
}
