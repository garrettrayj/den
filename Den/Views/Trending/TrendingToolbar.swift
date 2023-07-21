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

struct TrendingToolbar: CustomizableToolbarContent {
    #if !os(macOS)
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    #endif

    @ObservedObject var profile: Profile

    @Binding var hideRead: Bool

    var unreadCount: Int {
        profile.trends.containingUnread().count
    }

    var itemsFromTrends: [Item] {
        return profile.trends.flatMap { $0.items }
    }

    var body: some CustomizableToolbarContent {
        #if os(macOS)
        ToolbarItem(id: "TrendingFilterRead") {
            FilterReadButton(hideRead: $hideRead)
        }
        ToolbarItem(id: "TrendingToggleRead") {
            ToggleReadButton(unreadCount: unreadCount) {
                await HistoryUtility.toggleReadUnread(items: itemsFromTrends)
                profile.objectWillChange.send()
            }
        }
        #else
        if horizontalSizeClass == .compact {
            ToolbarItem(id: "TrendingMenu", placement: .primaryAction) {
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
        } else {
            ToolbarItem(id: "TrendingFilterRead", placement: .primaryAction) {
                FilterReadButton(hideRead: $hideRead)
            }
            ToolbarItem(id: "TrendingToggleRead", placement: .primaryAction) {
                ToggleReadButton(unreadCount: unreadCount) {
                    await HistoryUtility.toggleReadUnread(items: itemsFromTrends)
                    profile.objectWillChange.send()
                }
            }
        }
        #endif
    }
}
