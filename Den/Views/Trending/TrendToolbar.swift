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
    #if !os(macOS)
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    #endif

    @ObservedObject var trend: Trend
    @ObservedObject var profile: Profile

    @Binding var hideRead: Bool

    let items: [Item]

    var body: some ToolbarContent {
        #if os(macOS)
        ToolbarItem {
            FilterReadButton(hideRead: $hideRead)
        }
        ToolbarItem {
            MarkAllReadUnreadButton(unreadCount: items.unread().count) {
                await HistoryUtility.toggleReadUnread(items: Array(items))
                trend.objectWillChange.send()
                profile.objectWillChange.send()
                if hideRead {
                    dismiss()
                }
            }
        }
        #else
        if horizontalSizeClass == .compact {
            ToolbarItem(placement: .bottomBar) {
                FilterReadButton(hideRead: $hideRead)
            }
            ToolbarItem(placement: .bottomBar) {
                Spacer()
            }
            ToolbarItem(placement: .bottomBar) {
                MarkAllReadUnreadButton(unreadCount: items.unread().count) {
                    await HistoryUtility.toggleReadUnread(items: Array(items))
                    trend.objectWillChange.send()
                    profile.objectWillChange.send()
                    if hideRead {
                        dismiss()
                    }
                }
            }
        } else {
            ToolbarItem(placement: .primaryAction) {
                FilterReadButton(hideRead: $hideRead)
            }
            ToolbarItem(placement: .primaryAction) {
                MarkAllReadUnreadButton(unreadCount: items.unread().count) {
                    await HistoryUtility.toggleReadUnread(items: Array(items))
                    trend.objectWillChange.send()
                    profile.objectWillChange.send()
                    if hideRead {
                        dismiss()
                    }
                }
            }
        }
        #endif
    }
}
