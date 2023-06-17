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
    @Environment(\.managedObjectContext) private var viewContext
    
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
            FeedSettingsButton(feed: feed)
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
            FeedSettingsButton(feed: feed).buttonStyle(ToolbarButtonStyle())
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
