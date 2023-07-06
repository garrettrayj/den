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

    var body: some ToolbarContent {
        ToolbarItem {
            if let url = item.link {
                OpenInBrowserButton(url: url)
            }
        }
        ToolbarItem {
            if let url = item.link {
                ShareButton(url: url)
            }
        }
    }
}
