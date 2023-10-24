//
//  TrendingToolbar.swift
//  Den
//
//  Created by Garrett Johnson on 11/13/22.
//  Copyright © 2022 Garrett Johnson
//

import SwiftUI

struct TrendingToolbar: ToolbarContent {
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

    var body: some ToolbarContent {
        #if os(macOS)
        ToolbarItem {
            FilterReadButton(hideRead: $hideRead)
        }
        ToolbarItem {
            MarkAllReadUnreadButton(unreadCount: unreadCount) {
                await HistoryUtility.toggleReadUnread(items: itemsFromTrends)
                profile.objectWillChange.send()
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
                MarkAllReadUnreadButton(unreadCount: unreadCount) {
                    await HistoryUtility.toggleReadUnread(items: itemsFromTrends)
                    profile.objectWillChange.send()
                }
            }
        } else {
            ToolbarItem(placement: .primaryAction) {
                FilterReadButton(hideRead: $hideRead)
            }
            ToolbarItem(placement: .primaryAction) {
                MarkAllReadUnreadButton(unreadCount: unreadCount) {
                    await HistoryUtility.toggleReadUnread(items: itemsFromTrends)
                    profile.objectWillChange.send()
                }
            }
        }
        #endif
    }
}
