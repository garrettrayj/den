//
//  BookmarkToolbar.swift
//  Den
//
//  Created by Garrett Johnson on 9/15/23.
//  Copyright © 2023 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

struct BookmarkToolbar: ToolbarContent {
    @Environment(\.userTint) private var userTint
    
    @ObservedObject var bookmark: Bookmark

    var body: some ToolbarContent {
        // Same buttons, but primaryAction placement causes the app to crash on macOS
        // and no placement causes the buttons to be combined into a menu on iOS.
        #if os(macOS)
        ToolbarItem {
            if let url = bookmark.link {
                OpenInBrowserButton(url: url, tintColor: userTint)
            }
        }
        ToolbarItem {
            if let url = bookmark.link {
                ShareButton(url: url)
            }
        }
        #else
        ToolbarItem(placement: .primaryAction) {
            if let url = bookmark.link {
                OpenInBrowserButton(url: url, tintColor: userTint)
            }
        }
        ToolbarItem(placement: .primaryAction) {
            if let url = bookmark.link {
                ShareButton(url: url)
            }
        }
        #endif
    }
}
