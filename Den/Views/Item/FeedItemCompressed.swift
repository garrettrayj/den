//
//  FeedItemCompressed.swift
//  Den
//
//  Created by Garrett Johnson on 2/27/23.
//  Copyright © 2023 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

struct FeedItemCompressed: View {
    @ObservedObject var item: Item
    @ObservedObject var feed: Feed
    @ObservedObject var profile: Profile

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            FeedNavLink(feed: feed)
                .buttonStyle(FeedTitleButtonStyle())

            Divider()

            ItemActionView(item: item, feed: feed, profile: profile) {
                ItemCompressed(item: item, feed: feed)
            }
        }
        .background(SecondaryGroupedBackground())
        .modifier(RoundedContainerModifier())
    }
}
