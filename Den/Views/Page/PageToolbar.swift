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
    @ObservedObject var page: Page
    @ObservedObject var profile: Profile

    @Binding var hideRead: Bool
    @Binding var pageLayout: PageLayout

    let items: FetchedResults<Item>

    var body: some ToolbarContent {
        #if os(macOS)
        ToolbarItem {
            CommonStatus(profile: profile)
        }
        ToolbarItem {
            PageLayoutPicker(pageLayout: $pageLayout).pickerStyle(.inline)
        }
        ToolbarItem {
            NavigationLink(value: SubDetailPanel.pageSettings(page)) {
                Label {
                    Text("Page Settings", comment: "Button label.")
                } icon: {
                    Image(systemName: "wrench")
                }
            }
            .buttonStyle(ToolbarButtonStyle())
            .accessibilityIdentifier("page-settings-button")
        }
        ToolbarItem {
            FilterReadButton(hideRead: $hideRead) {
                page.objectWillChange.send()
            }
            .buttonStyle(ToolbarButtonStyle())
        }
        ToolbarItem {
            ToggleReadButton(unreadCount: items.unread().count) {
                await HistoryUtility.toggleReadUnread(items: Array(items))
                page.objectWillChange.send()
                page.feedsArray.forEach { $0.objectWillChange.send() }
            }
            .buttonStyle(ToolbarButtonStyle())
        }
        #else
        ToolbarItem {
            Menu {
                PageLayoutPicker(pageLayout: $pageLayout)
                AddFeedButton(page: page)
                NavigationLink(value: SubDetailPanel.pageSettings(page)) {
                    Label {
                        Text("Page Settings", comment: "Button label.")
                    } icon: {
                        Image(systemName: "wrench")
                    }
                }
                .accessibilityIdentifier("page-settings-button")
            } label: {
                Label {
                    Text("Page Menu", comment: "Menu label.")
                } icon: {
                    Image(systemName: "ellipsis.circle")
                }
            }
            .accessibilityIdentifier("page-menu")
        }
        
        ToolbarItem(placement: .bottomBar) {
            FilterReadButton(hideRead: $hideRead) {
                page.objectWillChange.send()
            }
            .buttonStyle(PlainToolbarButtonStyle())
        }
        ToolbarItem(placement: .bottomBar) { Spacer() }
        ToolbarItem(placement: .bottomBar) {
            CommonStatus(profile: profile)
        }
        ToolbarItem(placement: .bottomBar) { Spacer() }
        ToolbarItem(placement: .bottomBar) {
            ToggleReadButton(unreadCount: items.unread().count) {
                await HistoryUtility.toggleReadUnread(items: Array(items))
                page.objectWillChange.send()
                page.feedsArray.forEach { $0.objectWillChange.send() }
            }
            .buttonStyle(PlainToolbarButtonStyle())
        }
        #endif
    }
}
