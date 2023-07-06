//
//  TrendingToolbar.swift
//  Den
//
//  Created by Garrett Johnson on 11/13/22.
//  Copyright © 2022 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

struct TrendingToolbar: ToolbarContent {
    @ObservedObject var profile: Profile

    @Binding var hideRead: Bool

    var unreadCount: Int {
        profile.trends.containingUnread().count
    }

    var itemsFromTrends: [Item] {
        return profile.trends.flatMap { $0.items }
    }

    var body: some ToolbarContent {
        #if os(macOS)
        ToolbarItem {
            CommonStatus(profile: profile)
        }
        ToolbarItem {
            FilterReadButton(hideRead: $hideRead)
        }
        ToolbarItem {
            ToggleReadButton(unreadCount: unreadCount) {
                await HistoryUtility.toggleReadUnread(items: itemsFromTrends)
                profile.objectWillChange.send()
            }
        }
        #else
        ToolbarItem {
            Menu {
                ToggleReadButton(unreadCount: unreadCount) {
                    await HistoryUtility.toggleReadUnread(items: itemsFromTrends)
                    profile.objectWillChange.send()
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
        #endif
    }
}
