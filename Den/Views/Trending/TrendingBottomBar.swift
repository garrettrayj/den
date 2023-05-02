//
//  TrendingBottomBar.swift
//  Den
//
//  Created by Garrett Johnson on 11/13/22.
//  Copyright © 2022 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import CoreData
import SwiftUI

struct TrendingBottomBar: ToolbarContent {
    @ObservedObject var profile: Profile

    @Binding var hideRead: Bool

    var unreadCount: Int {
        profile.trends.containingUnread().count
    }

    var itemsFromTrends: [Item] {
        return profile.trends.flatMap { $0.items }
    }

    var body: some ToolbarContent {
        ToolbarItem(placement: .bottomBar) {
            FilterReadButton(hideRead: $hideRead) { }
        }
        ToolbarItemGroup(placement: .bottomBar) {
            Spacer()
            CommonStatus(
                profile: profile,
                unreadCount: unreadCount,
                unreadLabel: "with Unread"
            )
            Spacer()
        }
        ToolbarItem(placement: .bottomBar) {
            ToggleReadButton(unreadCount: unreadCount) {
                await HistoryUtility.toggleReadUnread(items: itemsFromTrends)
                profile.objectWillChange.send()
            }
        }
    }
}
