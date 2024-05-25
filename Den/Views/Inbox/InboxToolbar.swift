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

    @Binding var hideRead: Bool

    let items: FetchedResults<Item>

    var body: some ToolbarContent {
        #if os(macOS)
        ToolbarItem {
            FilterReadButton(hideRead: $hideRead)
        }
        ToolbarItem {
            MarkAllReadUnreadButton(allRead: items.unread.isEmpty && !items.isEmpty) {
                await HistoryUtility.toggleReadUnread(
                    items: Array(items),
                    container: dataController.container
                )
            }
        }
        #else
        if horizontalSizeClass == .compact {
            ToolbarItem(placement: .bottomBar) {
                FilterReadButton(hideRead: $hideRead)
            }
            ToolbarItem(placement: .status) {
                CommonStatus()
            }
            ToolbarItem(placement: .bottomBar) {
                MarkAllReadUnreadButton(allRead: items.unread.isEmpty) {
                    await HistoryUtility.toggleReadUnread(
                        items: Array(items),
                        container: dataController.container
                    )
                }
            }
        } else {
            ToolbarItem {
                FilterReadButton(hideRead: $hideRead)
            }
            ToolbarItem {
                MarkAllReadUnreadButton(allRead: items.unread.isEmpty && !items.isEmpty) {
                    await HistoryUtility.toggleReadUnread(
                        items: Array(items),
                        container: dataController.container
                    )
                }
            }
        }
        #endif
    }
}
