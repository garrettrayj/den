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

struct SearchToolbar: CustomizableToolbarContent {
    #if !os(macOS)
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    #endif

    @ObservedObject var profile: Profile

    @Binding var hideRead: Bool

    let query: String
    let items: FetchedResults<Item>

    var body: some CustomizableToolbarContent {
        #if os(macOS)
        ToolbarItem(id: "SearchStatus") {
            SearchStatus(resultCount: items.count, query: query)
        }
        ToolbarItem(id: "SearchFilterRead") {
            FilterReadButton(hideRead: $hideRead)
        }
        ToolbarItem(id: "SearchToggleRead") {
            ToggleReadButton(unreadCount: items.unread().count) {
                await HistoryUtility.toggleReadUnread(items: Array(items))
            }
        }
        #else
        if horizontalSizeClass == .compact {
            ToolbarItem(id: "SearchMenu", placement: .primaryAction) {
                Menu {
                    ToggleReadButton(unreadCount: items.unread().count) {
                        await HistoryUtility.toggleReadUnread(items: Array(items))
                    }
                    FilterReadButton(hideRead: $hideRead)
                } label: {
                    Label {
                        Text("Menu", comment: "Button label.")
                    } icon: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
            }
        } else {
            ToolbarItem(id: "SearchFilterRead", placement: .primaryAction) {
                FilterReadButton(hideRead: $hideRead)
            }
            ToolbarItem(id: "SearchToggleRead", placement: .primaryAction) {
                ToggleReadButton(unreadCount: items.unread().count) {
                    await HistoryUtility.toggleReadUnread(items: Array(items))
                }
            }
        }

        ToolbarItem(id: "SearchStatus", placement: .bottomBar) {
            SearchStatus(resultCount: items.count, query: query)
        }
        #endif
    }
}
