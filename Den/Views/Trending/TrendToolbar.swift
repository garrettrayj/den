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
    @Environment(\.modelContext) private var modelContext

    @Bindable var trend: Trend

    let items: [Item]
    
    @AppStorage("HideRead") private var hideRead: Bool = false

    var body: some ToolbarContent {
        #if os(macOS)
        ToolbarItem {
            FilterReadButton()
        }
        ToolbarItem {
            MarkAllReadUnreadButton(allRead: items.unread.isEmpty) {
                HistoryUtility.toggleReadUnread(modelContext: modelContext, items: items)
                if hideRead { dismiss() }
            }
        }
        #else
        if horizontalSizeClass == .compact {
            ToolbarItem(placement: .bottomBar) {
                FilterReadButton()
            }
            ToolbarItem(placement: .status) {
                CommonStatus()
            }
            ToolbarItem(placement: .bottomBar) {
                MarkAllReadUnreadButton(allRead: items.unread.isEmpty) {
                    HistoryUtility.toggleReadUnread(modelContext: modelContext, items: items)
                    if hideRead { dismiss() }
                }
            }
        } else {
            ToolbarItem {
                FilterReadButton()
            }
            ToolbarItem {
                MarkAllReadUnreadButton(allRead: items.unread.isEmpty) {
                    HistoryUtility.toggleReadUnread(modelContext: modelContext, items: items)
                    if hideRead { dismiss() }
                }
            }
        }
        #endif
    }
}
