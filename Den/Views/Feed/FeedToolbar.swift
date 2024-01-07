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
    @ObservedObject var profile: Profile

    @Binding var hideRead: Bool
    @Binding var showingInspector: Bool

    let items: [Item]

    var body: some ToolbarContent {
        #if os(macOS)
        ToolbarItem {
            InspectorToggleButton(showingInspector: $showingInspector)
        }
        ToolbarItem {
            FilterReadButton(hideRead: $hideRead)
        }
        ToolbarItem {
            MarkAllReadUnreadButton(allRead: items.unread().isEmpty) {
                await HistoryUtility.toggleReadUnread(items: Array(items))
            }
        }
        #else
        ToolbarTitleMenu {
            RenameButton()
            PagePicker(profile: profile, selection: $feed.page).pickerStyle(.menu)
            DeleteFeedButton(feed: feed)
        }
        
        if horizontalSizeClass == .compact {
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
                MarkAllReadUnreadButton(allRead: items.unread().isEmpty) {
                    await HistoryUtility.toggleReadUnread(items: Array(items))
                }
            }
        } else {
            ToolbarItem {
                InspectorToggleButton(showingInspector: $showingInspector)
            }
            ToolbarItem {
                FilterReadButton(hideRead: $hideRead)
            }
            ToolbarItem {
                MarkAllReadUnreadButton(allRead: items.unread().isEmpty) {
                    await HistoryUtility.toggleReadUnread(items: Array(items))
                }
            }
        }
        #endif
    }
}
