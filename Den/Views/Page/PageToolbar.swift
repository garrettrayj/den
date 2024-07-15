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
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    @ObservedObject var page: Page

    @Binding var hideRead: Bool
    @Binding var pageLayout: PageLayout
    @Binding var showingDeleteAlert: Bool
    @Binding var showingIconSelector: Bool

    let items: FetchedResults<Item>

    var body: some ToolbarContent {
        #if os(macOS)
        ToolbarItem {
            PageLayoutPicker(pageLayout: $pageLayout).pickerStyle(.segmented)
        }
        ToolbarItem {
            ToggleReadFilterButton(hideRead: $hideRead)
        }
        ToolbarItem {
            MarkAllReadUnreadButton(allRead: items.unread.isEmpty) {
                HistoryUtility.toggleReadUnread(items: Array(items))
            }
        }
        #else
        ToolbarTitleMenu {
            RenameButton()
            IconSelectorButton(showingIconSelector: $showingIconSelector, symbol: $page.wrappedSymbol)
            Button(role: .destructive) {
                showingDeleteAlert = true
            } label: {
                DeleteLabel()
            }
        }
        
        if horizontalSizeClass == .compact {
            ToolbarItem {
                PageLayoutPicker(pageLayout: $pageLayout)
                    .pickerStyle(.menu)
                    .labelStyle(.iconOnly)
                    .padding(.trailing, -12)
            }
            ToolbarItem(placement: .bottomBar) {
                ToggleReadFilterButton(hideRead: $hideRead)
            }
            ToolbarItem(placement: .status) {
                CommonStatus()
            }
            ToolbarItem(placement: .bottomBar) {
                MarkAllReadUnreadButton(allRead: items.unread.isEmpty) {
                    HistoryUtility.toggleReadUnread(items: Array(items))
                }
            }
        } else {
            ToolbarItem {
                PageLayoutPicker(pageLayout: $pageLayout).pickerStyle(.menu).labelStyle(.iconOnly)
            }
            ToolbarItem {
                ToggleReadFilterButton(hideRead: $hideRead)
            }
            ToolbarItem {
                MarkAllReadUnreadButton(allRead: items.unread.isEmpty) {
                    HistoryUtility.toggleReadUnread(items: Array(items))
                }
            }
        }
        #endif
    }
}
