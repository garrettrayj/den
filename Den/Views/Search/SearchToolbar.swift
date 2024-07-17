//
//  SearchToolbar.swift
//  Den
//
//  Created by Garrett Johnson on 1/3/24.
//  Copyright © 2024 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

struct SearchToolbar: ToolbarContent {
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    
    @EnvironmentObject private var dataController: DataController

    let query: String
    let items: FetchedResults<Item>

    var body: some ToolbarContent {
        #if os(macOS)
        ToolbarItem {
            ToggleReadFilterButton()
        }
        ToolbarItem {
            MarkAllReadUnreadButton(allRead: items.unread.isEmpty) {
                HistoryUtility.toggleReadUnread(
                    container: dataController.container,
                    items: Array(items)
                )
            }
        }
        #else
        if horizontalSizeClass == .compact {
            ToolbarItem(placement: .bottomBar) {
                ToggleReadFilterButton(hideRead: $hideRead)
            }
            ToolbarItem(placement: .status) {
                Text("Showing results for “\(query)”", comment: "Search status.")
                    .font(.caption)
            }
            ToolbarItem(placement: .bottomBar) {
                MarkAllReadUnreadButton(allRead: items.unread.isEmpty) {
                    HistoryUtility.toggleReadUnread(items: Array(items))
                }
            }
        } else {
            ToolbarItem {
                ToggleReadFilterButton(hideRead: $hideRead)
            }
            ToolbarItem {
                MarkAllReadUnreadButton(allRead: items.unread.isEmpty) {
                    HistoryUtility.toggleReadUnread(items: Array(items))
                }
            }
            ToolbarItem(placement: .status) {
                Text("Showing results for “\(query)”", comment: "Search status.")
                    .font(.caption)
            }
        }
        #endif
    }
}
