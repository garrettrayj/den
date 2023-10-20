//
//  BrowserFormatMenu.swift
//  Den
//
//  Created by Garrett Johnson on 10/19/23.
//  Copyright © 2023 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

struct BrowserFormatMenu: View {
    @ObservedObject var browserViewModel: BrowserViewModel
    
    @Binding var browserZoom: PageZoomLevel
    
    var body: some View {
        if browserViewModel.isReaderable {
            Menu {
                ShowReaderButton(browserViewModel: browserViewModel)
                ToggleBlocklistsButton(browserViewModel: browserViewModel)
                #if os(macOS)
                ZoomControlGroup(zoomLevel: $browserZoom)
                #endif
            } label: {
                Label {
                    Text("Formatting", comment: "Button label.")
                } icon: {
                    Image(systemName: "doc.plaintext")
                }
            } primaryAction: {
                browserViewModel.toggleReader()
            }
        } else {
            Menu {
                ToggleBlocklistsButton(browserViewModel: browserViewModel)
                #if os(macOS)
                ZoomControlGroup(zoomLevel: $browserZoom)
                #endif
            } label: {
                Label {
                    Text("Formatting", comment: "Button label.")
                } icon: {
                    Image(systemName: "textformat.size")
                }
            }
        }
    }
}
