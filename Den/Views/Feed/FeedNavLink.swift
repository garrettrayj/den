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
    @Bindable var feed: Feed

    var body: some View {
        NavigationLink(value: SubDetailPanel.feed(feed.persistentModelID)) {
            HStack {
                FeedTitleLabel(feed: feed)
                    .modifier(DraggableFeedModifier(feed: feed))
                    .help(
                        Text(
                            "Drag to move feed to another page.",
                            comment: "Draggable help text."
                        )
                    )
                Spacer()
                ButtonChevron()
            }
        }
        .accessibilityIdentifier("FeedNavLink")
    }
}
