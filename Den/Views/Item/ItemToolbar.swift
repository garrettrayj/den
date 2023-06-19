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
    @ObservedObject var feed: Feed

    var body: some ToolbarContent {
        #if os(macOS)
        ToolbarItem {
            if let url = item.link {
                OpenInBrowserButton(url: url)
            }
        }
        #else
        ToolbarItem(placement: .bottomBar) {
            Spacer()
        }
        ToolbarItem(placement: .bottomBar) {
            if let url = item.link {
                OpenInBrowserButton(url: url, readerMode: feed.readerMode)
                    
            }
        }
        #endif
        
        ToolbarItem {
            if let url = item.link {
                ShareButton(url: url)
            }
        }
    }
}
