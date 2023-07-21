//
//  FeedToolbar.swift
//  Den
//
//  Created by Garrett Johnson on 11/13/22.
//  Copyright © 2022 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

struct FeedToolbar: CustomizableToolbarContent {
    #if !os(macOS)
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    #endif

    @ObservedObject var feed: Feed
    @ObservedObject var profile: Profile

    @Binding var hideRead: Bool
    @Binding var showingFeedConfiguration: Bool

    let items: FetchedResults<Item>

    var body: some CustomizableToolbarContent {
        #if os(macOS)
        ToolbarItem(id: "FeedSettings") {
            ConfigureFeedButton(feed: feed, showingFeedConfiguration: $showingFeedConfiguration)
        }
        ToolbarItem(id: "FeedFilterRead") {
            FilterReadButton(hideRead: $hideRead)
        }
        ToolbarItem(id: "FeedToggleRead") {
            ToggleReadButton(unreadCount: items.unread().count) {
                await HistoryUtility.toggleReadUnread(items: Array(items))
                feed.objectWillChange.send()
            }
        }
        #else
        if horizontalSizeClass == .compact {
            ToolbarItem(id: "FeedMenu", placement: .primaryAction) {
                Menu {
                    ToggleReadButton(unreadCount: items.unread().count) {
                        await HistoryUtility.toggleReadUnread(items: Array(items))
                        feed.objectWillChange.send()
                    }
                    FilterReadButton(hideRead: $hideRead)
                    ConfigureFeedButton(feed: feed, showingFeedConfiguration: $showingFeedConfiguration)
                } label: {
                    Label {
                        Text("Menu", comment: "Button label.")
                    } icon: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
                .accessibilityIdentifier("FeedMenu")
            }
        } else {
            ToolbarItem(id: "FeedSettings", placement: .primaryAction) {
                ConfigureFeedButton(feed: feed, showingFeedConfiguration: $showingFeedConfiguration)
            }
            ToolbarItem(id: "FeedFilterRead", placement: .primaryAction) {
                FilterReadButton(hideRead: $hideRead)
            }
            ToolbarItem(id: "FeedToggleRead", placement: .primaryAction) {
                ToggleReadButton(unreadCount: items.unread().count) {
                    await HistoryUtility.toggleReadUnread(items: Array(items))
                    feed.objectWillChange.send()
                }
            }
        }
        #endif
    }
}
