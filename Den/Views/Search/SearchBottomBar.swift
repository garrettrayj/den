//
//  SearchBottomBar.swift
//  Den
//
//  Created by Garrett Johnson on 4/12/23.
//  Copyright © 2023 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

struct SearchBottomBar: ToolbarContent {
    @ObservedObject var profile: Profile

    @Binding var hideRead: Bool

    var query: String
    let items: FetchedResults<Item>

    var body: some ToolbarContent {
        ToolbarItem(placement: .bottomBar) {
            FilterReadButton(hideRead: $hideRead) {
                profile.objectWillChange.send()
            }
        }
        ToolbarItemGroup(placement: .bottomBar) {
            Spacer()
            SearchStatus(unreadCount: items.unread().count, totalCount: items.count, query: query)
            Spacer()
        }
        ToolbarItem(placement: .bottomBar) {
            ToggleReadButton(unreadCount: items.unread().count) {
                await HistoryUtility.toggleReadUnread(items: Array(items))
            }
        }
    }
}
