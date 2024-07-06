//
//  Bookmarks.swift
//  Den
//
//  Created by Garrett Johnson on 7/1/24.
//  Copyright © 2024 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

struct Bookmarks: View {
    @AppStorage("BookmarksLayout") private var tagLayout: TagLayout = .previews

    var body: some View {
        WithBookmarks { bookmarks in
            if bookmarks.isEmpty {
                ContentUnavailable {
                    Label {
                        Text("No Bookmarks", comment: "Content unavailable title.")
                    } icon: {
                        Image(systemName: "bookmark")
                    }
                }
            } else if tagLayout == .list {
                BookmarksTableLayout(bookmarks: bookmarks)
            } else {
                BookmarksSpreadLayout(bookmarks: bookmarks)
            }
        }
        .navigationTitle(Text("Bookmarks", comment: "Navigation title."))
        .toolbar {
            ToolbarItem {
                BookmarksLayoutPicker(tagLayout: $tagLayout)
                #if os(macOS)
                .pickerStyle(.inline)
                #else
                .pickerStyle(.menu)
                .labelStyle(.iconOnly)
                .padding(.trailing, -12)
                #endif
            }
        }
    }
}
