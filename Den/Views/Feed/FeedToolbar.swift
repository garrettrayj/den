//
//  FeedToolbar.swift
//  Den
//
//  Created by Garrett Johnson on 11/13/22.
//  Copyright © 2022 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

struct FeedToolbar: ToolbarContent {
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    
    @EnvironmentObject private var dataController: DataController

    @ObservedObject var feed: Feed

    @Binding var showingDeleteAlert: Bool
    @Binding var showingInspector: Bool

    let items: FetchedResults<Item>

    var body: some ToolbarContent {
        #if os(macOS)
        ToolbarItem {
            InspectorToggleButton(showingInspector: $showingInspector)
        }
        ToolbarItem {
            ToggleReadFilterButton()
        }
        ToolbarItem {
            MarkAllReadUnreadButton(allRead: items.unread.isEmpty) {
                HistoryUtility.toggleReadUnread(
                    container: dataController.container,
                    items: Array(items)
                )
            }
        }
        #else
        ToolbarTitleMenu {
            RenameButton()
            PagePicker(
                selection: $feed.page,
                labelText: Text("Move", comment: "Picker label.")
            ).pickerStyle(.menu)
            Button(role: .destructive) {
                showingDeleteAlert = true
            } label: {
                DeleteLabel()
            }
        }
        
        if horizontalSizeClass == .compact {
            ToolbarItem {
                InspectorToggleButton(showingInspector: $showingInspector)
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
                InspectorToggleButton(showingInspector: $showingInspector)
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
