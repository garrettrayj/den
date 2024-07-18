//
//  TrendToolbar.swift
//  Den
//
//  Created by Garrett Johnson on 11/13/22.
//  Copyright © 2022 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

struct TrendToolbar: ToolbarContent {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    
    @EnvironmentObject private var dataController: DataController

    @ObservedObject var trend: Trend

    @Binding var hideRead: Bool

    let items: [Item]

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
                if hideRead { dismiss() }
            }
        }
        #else
        if horizontalSizeClass == .compact {
            ToolbarItem(placement: .bottomBar) {
                ToggleReadFilterButton()
            }
            ToolbarItem(placement: .status) {
                CommonStatus()
            }
            ToolbarItem(placement: .bottomBar) {
                MarkAllReadUnreadButton(allRead: items.unread.isEmpty) {
                    HistoryUtility.toggleReadUnread(
                        container: dataController.container,
                        items: Array(items)
                    )
                    if hideRead { dismiss() }
                }
            }
        } else {
            ToolbarItem {
                ToggleReadFilterButton()
            }
            ToolbarItem {
                MarkAllReadUnreadButton(allRead: items.unread.isEmpty) {
                    HistoryUtility.toggleReadUnread(
                        container: dataController.container,
                        items: Array(items)
                    )
                    if hideRead { dismiss() }
                }
            }
        }
        #endif
    }
}
