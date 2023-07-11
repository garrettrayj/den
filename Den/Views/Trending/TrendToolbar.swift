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

    let items: FetchedResults<Item>

    var body: some ToolbarContent {
        #if os(macOS)
        ToolbarItem {
            CommonStatus(profile: profile)
        }
        ToolbarItem {
            FilterReadButton(hideRead: $hideRead)
        }
        ToolbarItem {
            ToggleReadButton(unreadCount: items.unread().count) {
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
            ToolbarItem {
                Menu {
                    ToggleReadButton(unreadCount: items.unread().count) {
                        await HistoryUtility.toggleReadUnread(items: Array(items))
                        trend.objectWillChange.send()
                        profile.objectWillChange.send()
                        if hideRead {
                            dismiss()
                        }
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
            ToolbarItem {
                FilterReadButton(hideRead: $hideRead)
            }
            ToolbarItem {
                ToggleReadButton(unreadCount: items.unread().count) {
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
