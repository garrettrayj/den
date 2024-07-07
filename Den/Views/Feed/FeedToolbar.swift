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
    @Environment(\.modelContext) private var modelContext

    @Bindable var feed: Feed

    @Binding var showingDeleteAlert: Bool
    
    @SceneStorage("ShowingFeedInspector") private var showingInspector = false

    let items: [Item]

    var body: some ToolbarContent {
        #if os(macOS)
        ToolbarItem {
            InspectorToggleButton(initialValue: false, storageKey: "ShowingFeedInspector")
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
                InspectorToggleButton(initialValue: false, storageKey: "ShowingFeedInspector")
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
                InspectorToggleButton(initialValue: false, storageKey: "ShowingFeedInspector")
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
