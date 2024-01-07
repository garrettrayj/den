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

    private var unreadCount: Int {
        profile.trends.containingUnread().count
    }

    private var itemsFromTrends: [Item] {
        return profile.trends.flatMap { $0.items }
    }

    var body: some ToolbarContent {
        #if os(macOS)
        ToolbarItem {
            FilterReadButton(hideRead: $hideRead)
        }
        ToolbarItem {
            MarkAllReadUnreadButton(allRead: unreadCount == 0) {
                await HistoryUtility.toggleReadUnread(items: itemsFromTrends)
                profile.objectWillChange.send()
            }
        }
        #else
        if horizontalSizeClass == .compact {
            ToolbarItem(placement: .bottomBar) {
                FilterReadButton(hideRead: $hideRead)
            }
            ToolbarItem(placement: .status) {
                TrendingStatus(profile: profile)
            }
            ToolbarItem(placement: .bottomBar) {
                MarkAllReadUnreadButton(allRead: unreadCount == 0) {
                    await HistoryUtility.toggleReadUnread(items: itemsFromTrends)
                    profile.objectWillChange.send()
                }
            }
        } else {
            ToolbarItem {
                FilterReadButton(hideRead: $hideRead)
            }
            ToolbarItem {
                MarkAllReadUnreadButton(allRead: unreadCount == 0) {
                    await HistoryUtility.toggleReadUnread(items: itemsFromTrends)
                    profile.objectWillChange.send()
                }
            }
        }
        #endif
    }
}
