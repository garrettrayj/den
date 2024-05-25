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

    @Binding var hideRead: Bool

    let query: String
    let items: FetchedResults<Item>

    var body: some ToolbarContent {
        #if os(macOS)
        ToolbarItem {
            FilterReadButton(hideRead: $hideRead)
        }
        ToolbarItem {
            MarkAllReadUnreadButton(allRead: items.unread.isEmpty) {
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
                Text("Showing results for “\(query)”", comment: "Bottom bar status.")
                    .font(.caption)
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
                MarkAllReadUnreadButton(allRead: items.unread.isEmpty) {
                    await HistoryUtility.toggleReadUnread(
                        items: Array(items),
                        container: dataController.container
                    )
                }
            }
            ToolbarItem(placement: .status) {
                Text("Showing results for “\(query)”", comment: "Bottom bar status.")
                    .font(.caption)
            }
        }
        #endif
    }
}
