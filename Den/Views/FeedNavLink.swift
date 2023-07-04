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
    
    // Padding properties to support deck page layout
    var leadingPadding: CGFloat = 0
    var trailingPadding: CGFloat = 0

    var body: some View {
        NavigationLink(value: SubDetailPanel.feed(feed)) {
            HStack {
                FeedTitleLabel(feed: feed)
                Spacer()
                ButtonChevron()
            }
            .padding(.leading, leadingPadding)
            .padding(.trailing, trailingPadding)
        }
        .accessibilityIdentifier("feed-button")
    }
}
