//
//  FeedView.swift
//  Den
//
//  Created by Garrett Johnson on 11/10/21.
//  Copyright © 2021 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import CoreData
import SwiftUI

struct FeedView: View {
    @Environment(\.dismiss) private var dismiss

    @ObservedObject var feed: Feed
    @ObservedObject var profile: Profile

    @Binding var hideRead: Bool

    var body: some View {
        if feed.managedObjectContext == nil {
            SplashNote(title: "Feed Deleted", symbol: "slash.circle")
        } else {
            WithItems(
                scopeObject: feed,
                includeExtras: true
            ) { items in
                FeedLayout(
                    feed: feed,
                    profile: profile,
                    hideRead: hideRead,
                    items: items.visibilityFiltered(hideRead ? false : nil)
                )
                .background(GroupedBackground())
                .toolbar {
                    ToolbarItemGroup(placement: .primaryAction) {
                        NavigationLink(value: FeedPanel.feedSettings(feed)) {
                            Label("Feed Settings", systemImage: "wrench")
                        }
                        .buttonStyle(ToolbarButtonStyle())
                        .accessibilityIdentifier("feed-settings-button")
                    }
                    ToolbarItemGroup(placement: .bottomBar) {
                        FeedBottomBar(
                            feed: feed,
                            profile: profile,
                            hideRead: $hideRead,
                            items: items
                        )
                    }
                }
                .onChange(of: feed.page) { _ in
                    dismiss()
                }
                .navigationTitle(feed.wrappedTitle)
                .navigationDestination(for: FeedPanel.self) { panel in
                    switch panel {
                    case .feedSettings(let feed):
                        FeedSettings(feed: feed)
                    }
                }
            }
        }
    }
}
