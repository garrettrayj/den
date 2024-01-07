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
    @Binding var showingIconSelector: Bool

    let items: [Item]

    var body: some ToolbarContent {
        #if os(macOS)
        ToolbarItem {
            PageLayoutPicker(pageLayout: $pageLayout).pickerStyle(.menu).labelStyle(.iconOnly)
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
            IconSelectorButton(showingIconSelector: $showingIconSelector, symbol: $page.wrappedSymbol)
            DeletePageButton(page: page)
        }
        
        if horizontalSizeClass == .compact {
            ToolbarItem {
                PageLayoutPicker(pageLayout: $pageLayout)
                    .pickerStyle(.menu)
                    .labelStyle(.iconOnly)
                    .padding(.trailing, -12)
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
                MarkAllReadUnreadButton(allRead: items.unread().isEmpty) {
                    await HistoryUtility.toggleReadUnread(items: Array(items))
                }
            }
        } else {
            ToolbarItem {
                PageLayoutPicker(pageLayout: $pageLayout).pickerStyle(.menu).labelStyle(.iconOnly)
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
