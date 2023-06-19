//
//  SearchToolbar.swift
//  Den
//
//  Created by Garrett Johnson on 4/12/23.
//  Copyright © 2023 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

struct SearchToolbar: ToolbarContent {
    @ObservedObject var profile: Profile

    @Binding var hideRead: Bool
    @Binding var query: String

    let items: FetchedResults<Item>

    var body: some ToolbarContent {
        #if os(iOS)
        ToolbarItem(placement: .bottomBar) {
            FilterReadButton(hideRead: $hideRead)
        }
        ToolbarItem(placement: .bottomBar) { Spacer() }
        ToolbarItem(placement: .bottomBar) {
            SearchStatus(unreadCount: items.unread().count, totalCount: items.count, query: query)
        }
        ToolbarItem(placement: .bottomBar) { Spacer() }
        ToolbarItem(placement: .bottomBar) {
            ToggleReadButton(unreadCount: items.unread().count) {
                await HistoryUtility.toggleReadUnread(items: Array(items))
            }
        }
        #else
        ToolbarItem {
            SearchStatus(unreadCount: items.unread().count, totalCount: items.count, query: query)
        }
        ToolbarItem {
            FilterReadButton(hideRead: $hideRead)
        }
        ToolbarItem {
            ToggleReadButton(unreadCount: items.unread().count) {
                await HistoryUtility.toggleReadUnread(items: Array(items))
            }
        }
        #endif
    }
}
