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

struct SearchBottomBar: View {
    @ObservedObject var profile: Profile

    @Binding var hideRead: Bool

    var query: String

    var body: some View {
        FilterReadButton(hideRead: $hideRead) {
            profile.objectWillChange.send()
        }
        Spacer()
        WithItems(
            scopeObject: profile,
            includeExtras: true,
            searchQuery: query
        ) { items in
            SearchStatus(unreadCount: items.unread().count, totalCount: items.count, query: query)
            Spacer()
            ToggleReadButton(unreadCount: items.unread().count) {
                await HistoryUtility.toggleReadUnread(items: Array(items))
            }
        }
    }
}
