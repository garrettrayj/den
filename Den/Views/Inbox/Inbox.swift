//
//  Inbox.swift
//  Den
//
//  Created by Garrett Johnson on 7/4/22.
//  Copyright © 2022 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

struct Inbox: View {
    @ObservedObject var profile: Profile

    @Binding var hideRead: Bool

    var body: some View {
        WithItems(scopeObject: profile) { items in
            InboxLayout(
                profile: profile,
                hideRead: hideRead,
                items: items.visibilityFiltered(hideRead ? false : nil)
            )
            .toolbar {
                ToolbarItemGroup(placement: .primaryAction) {
                    AddFeedButton()
                }
                InboxBottomBar(profile: profile, hideRead: $hideRead, items: items)
            }
            .navigationTitle("Inbox")
            .navigationDestination(for: DetailPanel.self) { detailPanel in
                switch detailPanel {
                case .feed(let feed):
                    FeedView(
                        feed: feed,
                        profile: profile,
                        hideRead: $hideRead
                    )
                case .item(let item):
                    ItemView(item: item, profile: profile)
                }
            }
        }
    }
}
