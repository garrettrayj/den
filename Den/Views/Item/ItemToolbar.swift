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

struct ItemToolbar: CustomizableToolbarContent {
    @ObservedObject var item: Item
    @ObservedObject var profile: Profile

    var body: some CustomizableToolbarContent {
        // Same buttons, but primaryAction placement causes the app to crash on macOS
        // and no placement causes the buttons to be combined into a menu on iOS.
        #if os(macOS)
        ToolbarItem(id: "ItemOpenInBrowser") {
            if let url = item.link {
                OpenInBrowserButton(url: url, tintColor: profile.tintColor)
            }
        }
        ToolbarItem(id: "ItemShare") {
            if let url = item.link {
                ShareButton(url: url)
            }
        }
        #else
        ToolbarItem(id: "ItemOpenInBrowser", placement: .primaryAction) {
            if let url = item.link {
                OpenInBrowserButton(url: url, tintColor: profile.tintColor)
            }
        }
        ToolbarItem(id: "ItemShare", placement: .primaryAction) {
            if let url = item.link {
                ShareButton(url: url)
            }
        }
        #endif
    }
}
