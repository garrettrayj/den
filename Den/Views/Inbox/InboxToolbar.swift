//
//  InboxToolbar.swift
//  Den
//
//  Created by Garrett Johnson on 11/13/22.
//  Copyright © 2022 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

struct InboxToolbar: ToolbarContent {
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    
    @EnvironmentObject private var dataController: DataController

    let items: FetchedResults<Item>

    var body: some ToolbarContent {
        #if os(macOS)
        ToolbarItem {
            ToggleReadFilterButton()
        }
        ToolbarItem {
            MarkAllReadUnreadButton(allRead: items.unread.isEmpty && !items.isEmpty) {
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
                CommonStatus()
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
                MarkAllReadUnreadButton(allRead: items.unread.isEmpty && !items.isEmpty) {
                    HistoryUtility.toggleReadUnread(items: Array(items))
                }
            }
        }
        #endif
    }
}
