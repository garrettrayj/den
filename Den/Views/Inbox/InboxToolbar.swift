//
//  InboxToolbar.swift
//  Den
//
//  Created by Garrett Johnson on 11/13/22.
//  Copyright © 2022 Garrett Johnson
//

import SwiftUI

struct InboxToolbar: ToolbarContent {
    #if !os(macOS)
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    #endif

    @ObservedObject var profile: Profile

    @Binding var hideRead: Bool
    @Binding var searchQuery: String

    let items: [Item]

    var body: some ToolbarContent {
        #if os(macOS)
        ToolbarItem {
            FilterReadButton(hideRead: $hideRead)
        }
        ToolbarItem {
            MarkAllReadUnreadButton(allRead: items.unread().count == 0 && items.count > 0) {
                await HistoryUtility.toggleReadUnread(items: Array(items))
            }
        }
        #else
        ToolbarItem(placement: .bottomBar) {
            FilterReadButton(hideRead: $hideRead)
        }
        ToolbarItem(placement: .status) {
            if searchQuery.isEmpty {
                CommonStatus(profile: profile, items: items)
            } else {
                SearchStatus(searchQuery: $searchQuery)
            }
        }
        ToolbarItem(placement: .bottomBar) {
            MarkAllReadUnreadButton(allRead: items.unread().count == 0) {
                await HistoryUtility.toggleReadUnread(items: Array(items))
            }
        }
        #endif
    }
}
