//
//  PageToolbar.swift
//  Den
//
//  Created by Garrett Johnson on 11/13/22.
//  Copyright © 2022 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import CoreData
import SwiftUI

struct PageToolbar: CustomizableToolbarContent {
    #if !os(macOS)
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    #endif
    
    @ObservedObject var page: Page
    @ObservedObject var profile: Profile

    @Binding var hideRead: Bool
    @Binding var pageLayout: PageLayout
    @Binding var showingSettings: Bool

    let items: FetchedResults<Item>

    var body: some CustomizableToolbarContent {
        #if os(macOS)
        ToolbarItem(id: "PageLayout") {
            PageLayoutPicker(pageLayout: $pageLayout)
                .labelStyle(.iconOnly)
        }
        ToolbarItem(id: "PageSettings") {
            PageSettingsButton(showingSettings: $showingSettings)
        }
        ToolbarItem(id: "PageFilterRead") {
            FilterReadButton(hideRead: $hideRead)
        }
        ToolbarItem(id: "PageToggleRead") {
            ToggleReadButton(unreadCount: items.unread().count) {
                await HistoryUtility.toggleReadUnread(items: Array(items))
                page.objectWillChange.send()
                page.feedsArray.forEach { $0.objectWillChange.send() }
            }
        }
        #else
        if horizontalSizeClass == .compact {
            ToolbarItem {
                Menu {
                    ToggleReadButton(unreadCount: items.unread().count) {
                        await HistoryUtility.toggleReadUnread(items: Array(items))
                        page.objectWillChange.send()
                        page.feedsArray.forEach { $0.objectWillChange.send() }
                    }
                    FilterReadButton(hideRead: $hideRead)
                    PageLayoutPicker(pageLayout: $pageLayout)
                    PageSettingsButton(showingSettings: $showingSettings)
                } label: {
                    Label {
                        Text("Menu", comment: "Button label.")
                    } icon: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
                .accessibilityIdentifier("PageMenu")
            }
        } else {
            ToolbarItem {
                PageLayoutPicker(pageLayout: $pageLayout)
            }
            ToolbarItem {
                PageSettingsButton(showingSettings: $showingSettings)
            }
            ToolbarItem {
                FilterReadButton(hideRead: $hideRead)
            }
            ToolbarItem {
                ToggleReadButton(unreadCount: items.unread().count) {
                    await HistoryUtility.toggleReadUnread(items: Array(items))
                    page.objectWillChange.send()
                    page.feedsArray.forEach { $0.objectWillChange.send() }
                }
            }
        }
        #endif
    }
}
