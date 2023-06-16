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

struct FeedToolbar: ToolbarContent {
    @ObservedObject var feed: Feed
    @ObservedObject var profile: Profile

    @Binding var hideRead: Bool

    let items: FetchedResults<Item>

    var body: some ToolbarContent {
        #if os(macOS)
        ToolbarItem {
            FeedStatus(feed: feed, unreadCount: items.unread().count)
        }
        ToolbarItem {
            NavigationLink(value: SubDetailPanel.feedSettings(feed)) {
                Label {
                    Text("Feed Settings", comment: "Button label.")
                } icon: {
                    Image(systemName: "wrench")
                }
            }
            .buttonStyle(ToolbarButtonStyle())
            .accessibilityIdentifier("feed-settings-button")
        }
        ToolbarItem {
            FilterReadButton(hideRead: $hideRead) {
                feed.objectWillChange.send()
            }
            .buttonStyle(ToolbarButtonStyle())
        }
        ToolbarItem {
            ToggleReadButton(unreadCount: items.unread().count) {
                await HistoryUtility.toggleReadUnread(items: Array(items))
                feed.objectWillChange.send()
            }
            .buttonStyle(ToolbarButtonStyle())
        }
        #else
        ToolbarItem {
            NavigationLink(value: SubDetailPanel.feedSettings(feed)) {
                Label {
                    Text("Feed Settings", comment: "Button label.")
                } icon: {
                    Image(systemName: "wrench")
                }
            }
            .buttonStyle(ToolbarButtonStyle())
            .accessibilityIdentifier("feed-settings-button")
        }
        ToolbarItem(placement: .bottomBar) {
            FilterReadButton(hideRead: $hideRead) {
                feed.objectWillChange.send()
            }.buttonStyle(PlainToolbarButtonStyle())
        }
        ToolbarItem(placement: .bottomBar) { Spacer() }
        ToolbarItem(placement: .bottomBar) {
            FeedStatus(feed: feed, unreadCount: items.unread().count)
        }
        ToolbarItem(placement: .bottomBar) { Spacer() }
        ToolbarItem(placement: .bottomBar) {
            ToggleReadButton(unreadCount: items.unread().count) {
                await HistoryUtility.toggleReadUnread(items: Array(items))
                feed.objectWillChange.send()
            }.buttonStyle(PlainToolbarButtonStyle())
        }
        #endif
    }
}
