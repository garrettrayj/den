//
//  PageToolbar.swift
//  Den
//
//  Created by Garrett Johnson on 11/13/22.
//  Copyright © 2022 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftData
import SwiftUI

struct PageToolbar: ToolbarContent {
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(\.modelContext) private var modelContext

    @Bindable var page: Page

    @Binding var pageLayout: PageLayout
    @Binding var showingDeleteAlert: Bool
    @Binding var showingIconSelector: Bool

    let items: [Item]

    var body: some ToolbarContent {
        #if os(macOS)
        ToolbarItem {
            PageLayoutPicker(pageLayout: $pageLayout).pickerStyle(.menu).labelStyle(.iconOnly)
        }
        ToolbarItem {
            FilterReadButton()
        }
        ToolbarItem {
            MarkAllReadUnreadButton(allRead: items.unread.isEmpty) {
                HistoryUtility.toggleReadUnread(modelContext: modelContext, items: items)
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
                FilterReadButton()
            }
            ToolbarItem(placement: .status) {
                CommonStatus()
            }
            ToolbarItem(placement: .bottomBar) {
                MarkAllReadUnreadButton(allRead: items.unread.isEmpty) {
                    HistoryUtility.toggleReadUnread(modelContext: modelContext, items: items)
                }
            }
        } else {
            ToolbarItem {
                PageLayoutPicker(pageLayout: $pageLayout).pickerStyle(.menu).labelStyle(.iconOnly)
            }
            ToolbarItem {
                FilterReadButton()
            }
            ToolbarItem {
                MarkAllReadUnreadButton(allRead: items.unread.isEmpty) {
                    HistoryUtility.toggleReadUnread(modelContext: modelContext, items: items)
                }
            }
        }
        #endif
    }
}
