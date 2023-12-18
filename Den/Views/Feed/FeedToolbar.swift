//
//  FeedToolbar.swift
//  Den
//
//  Created by Garrett Johnson on 11/13/22.
//  Copyright © 2022 Garrett Johnson
//

import SwiftUI

struct FeedToolbar: ToolbarContent {
    @ObservedObject var feed: Feed

    @Binding var hideRead: Bool
    @Binding var showingInspector: Bool

    let items: [Item]

    var body: some ToolbarContent {
        #if os(macOS)
        ToolbarItem {
            FilterReadButton(hideRead: $hideRead)
        }
        ToolbarItem {
            MarkAllReadUnreadButton(allRead: items.unread().count == 0) {
                await HistoryUtility.toggleReadUnread(items: Array(items))
            }
        }
        ToolbarItem {
            InspectorToggleButton(showingInspector: $showingInspector)
        }
        #else
        ToolbarItem {
            InspectorToggleButton(showingInspector: $showingInspector)
        }
        ToolbarItem(placement: .bottomBar) {
            FilterReadButton(hideRead: $hideRead)
        }
        ToolbarItem(placement: .status) {
            if let profile = feed.page?.profile {
                CommonStatus(profile: profile, items: items)
            }
        }
        ToolbarItem(placement: .bottomBar) {
            MarkAllReadUnreadButton(allRead: items.unread().count == 0) {
                await HistoryUtility.toggleReadUnread(items: Array(items))
            }
        }
        #endif
    }
}
