//
//  PageToolbar.swift
//  Den
//
//  Created by Garrett Johnson on 11/13/22.
//  Copyright © 2022 Garrett Johnson
//

import CoreData
import SwiftUI

struct PageToolbar: ToolbarContent {
    #if !os(macOS)
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    #endif

    @ObservedObject var page: Page

    @Binding var hideRead: Bool
    @Binding var pageLayout: PageLayout
    @Binding var showingInspector: Bool

    let items: [Item]

    var body: some ToolbarContent {
        #if os(macOS)
        ToolbarItem {
            PageLayoutPicker(pageLayout: $pageLayout).labelStyle(.iconOnly)
        }
        ToolbarItem {
            FilterReadButton(hideRead: $hideRead)
        }
        ToolbarItem {
            MarkAllReadUnreadButton(unreadCount: items.unread().count) {
                await HistoryUtility.toggleReadUnread(items: Array(items))
                page.objectWillChange.send()
                page.feedsArray.forEach { $0.objectWillChange.send() }
            }
        }
        ToolbarItem {
            InspectorToggleButton(showingInspector: $showingInspector)
        }
        #else
        if horizontalSizeClass == .compact {
            ToolbarItem {
                PageLayoutPicker(pageLayout: $pageLayout)
            }
            ToolbarItem {
                InspectorToggleButton(showingInspector: $showingInspector)
            }
            ToolbarItem(placement: .bottomBar) {
                FilterReadButton(hideRead: $hideRead)
            }
            ToolbarItem(placement: .status) {
                if let profile = page.profile {
                    CommonStatus(profile: profile, items: items)
                }
            }
            ToolbarItem(placement: .bottomBar) {
                MarkAllReadUnreadButton(unreadCount: items.unread().count) {
                    await HistoryUtility.toggleReadUnread(items: Array(items))
                    page.objectWillChange.send()
                    page.feedsArray.forEach { $0.objectWillChange.send() }
                }
            }
        } else {
            ToolbarItem(placement: .primaryAction) {
                PageLayoutPicker(pageLayout: $pageLayout)
            }
            ToolbarItem(placement: .primaryAction) {
                FilterReadButton(hideRead: $hideRead)
            }
            ToolbarItem(placement: .primaryAction) {
                MarkAllReadUnreadButton(unreadCount: items.unread().count) {
                    await HistoryUtility.toggleReadUnread(items: Array(items))
                    page.objectWillChange.send()
                    page.feedsArray.forEach { $0.objectWillChange.send() }
                }
            }
            ToolbarItem(placement: .primaryAction) {
                InspectorToggleButton(showingInspector: $showingInspector)
            }
        }
        #endif
    }
}
