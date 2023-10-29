//
//  FeedToolbar.swift
//  Den
//
//  Created by Garrett Johnson on 11/13/22.
//  Copyright © 2022 Garrett Johnson
//

import SwiftUI

struct FeedToolbar: ToolbarContent {
    #if !os(macOS)
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    #endif

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
            MarkAllReadUnreadButton(unreadCount: items.unread().count) {
                await HistoryUtility.toggleReadUnread(items: Array(items))
                feed.objectWillChange.send()
            }
        }
        ToolbarItem {
            InspectorToggleButton(showingInspector: $showingInspector)
        }
        #else
        if horizontalSizeClass == .compact {
            ToolbarItem {
                InspectorToggleButton(showingInspector: $showingInspector)
            }
            ToolbarItem(placement: .bottomBar) {
                FilterReadButton(hideRead: $hideRead)
            }
            ToolbarItem(placement: .bottomBar) {
                Spacer()
            }
            ToolbarItem(placement: .bottomBar) {
                if let profile = feed.page?.profile {
                    CommonStatus(profile: profile, items: items)
                }
            }
            ToolbarItem(placement: .bottomBar) {
                Spacer()
            }
            ToolbarItem(placement: .bottomBar) {
                MarkAllReadUnreadButton(unreadCount: items.unread().count) {
                    await HistoryUtility.toggleReadUnread(items: Array(items))
                    feed.objectWillChange.send()
                }
            }
        } else {
            ToolbarItem(placement: .primaryAction) {
                FilterReadButton(hideRead: $hideRead)
            }
            ToolbarItem(placement: .primaryAction) {
                MarkAllReadUnreadButton(unreadCount: items.unread().count) {
                    await HistoryUtility.toggleReadUnread(items: Array(items))
                    feed.objectWillChange.send()
                }
            }
            ToolbarItem(placement: .primaryAction) {
                InspectorToggleButton(showingInspector: $showingInspector)
            }
        }
        #endif
    }
}
