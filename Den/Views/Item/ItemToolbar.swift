//
//  ItemToolbar.swift
//  Den
//
//  Created by Garrett Johnson on 6/14/23.
//  Copyright © 2023 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

struct ItemToolbar: ToolbarContent {
    @ObservedObject var item: Item
    @ObservedObject var profile: Profile

    var body: some ToolbarContent {
        // Same buttons, but primaryAction placement causes the app to crash on macOS
        // and no placement causes the buttons to be combined into a menu on iOS.
        #if os(macOS)
        ToolbarItem {
            TagsMenu(item: item, profile: profile)
        }
        ToolbarItem {
            if let url = item.link {
                OpenInBrowserButton(url: url, tintColor: profile.tintColor)
            }
        }
        ToolbarItem {
            if let url = item.link {
                ShareButton(url: url)
            }
        }
        #else
        ToolbarItem(placement: .primaryAction) {
            TagsMenu(item: item, profile: profile)
        }
        ToolbarItem(placement: .primaryAction) {
            if let url = item.link {
                OpenInBrowserButton(url: url, tintColor: profile.tintColor)
            }
        }
        ToolbarItem(placement: .primaryAction) {
            if let url = item.link {
                ShareButton(url: url)
            }
        }
        #endif
    }
}
