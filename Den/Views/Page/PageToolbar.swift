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

struct PageToolbar: ToolbarContent {
    #if !os(macOS)
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    #endif

    @ObservedObject var page: Page

    @Binding var hideRead: Bool
    @Binding var pageLayout: PageLayout
    @Binding var showingPageConfiguration: Bool

    let items: FetchedResults<Item>

    var body: some ToolbarContent {
        #if os(macOS)
        ToolbarItem {
            PageLayoutPicker(pageLayout: $pageLayout)
                .pickerStyle(.inline)
        }
        ToolbarItem {
            ConfigurePageButton(showingPageConfiguration: $showingPageConfiguration)
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
        #else
        if horizontalSizeClass == .compact {
            ToolbarItem(id: "PageMenu", placement: .primaryAction) {
                Menu {
                    ToggleReadButton(unreadCount: items.unread().count) {
                        await HistoryUtility.toggleReadUnread(items: Array(items))
                        page.objectWillChange.send()
                        page.feedsArray.forEach { $0.objectWillChange.send() }
                    }
                    FilterReadButton(hideRead: $hideRead)
                    PageLayoutPicker(pageLayout: $pageLayout)
                    ConfigurePageButton(showingPageConfiguration: $showingPageConfiguration)
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
            ToolbarItem(placement: .primaryAction) {
                PageLayoutPicker(pageLayout: $pageLayout)
            }
            ToolbarItem(placement: .primaryAction) {
                ConfigurePageButton(showingPageConfiguration: $showingPageConfiguration)
            }
            ToolbarItem(placement: .primaryAction) {
                FilterReadButton(hideRead: $hideRead)
            }
            ToolbarItem(placement: .primaryAction) {
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
