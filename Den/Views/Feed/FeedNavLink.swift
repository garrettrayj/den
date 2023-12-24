//
//  FeedNavLink.swift
//  Den
//
//  Created by Garrett Johnson on 6/19/23.
//  Copyright © 2023 Garrett Johnson
//

import SwiftUI

struct FeedNavLink: View {
    @ObservedObject var feed: Feed

    var body: some View {
        NavigationLink(value: SubDetailPanel.feed(feed)) {
            HStack {
                FeedTitleLabel(feed: feed).modifier(DraggableFeedModifier(feed: feed))
                Spacer()
                ButtonChevron()
            }
        }
        .accessibilityIdentifier("FeedNavLink")
        .padding(.bottom, 1)
        .overlay(Divider(), alignment: .bottom)
    }
}
