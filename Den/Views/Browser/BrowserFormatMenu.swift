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
    
    var body: some View {
        Group {
            if browserViewModel.isReaderable {
                Menu {
                    ToggleReaderButton(browserViewModel: browserViewModel)
                    ToggleBlocklistsButton(browserViewModel: browserViewModel)
                    ToggleJavaScriptButton(browserViewModel: browserViewModel)
                    #if os(macOS)
                    BrowserZoom(browserViewModel: browserViewModel)
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
                    ToggleJavaScriptButton(browserViewModel: browserViewModel)
                    #if os(macOS)
                    BrowserZoom(browserViewModel: browserViewModel)
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
        .accessibilityLabel("FormatMenu")
    }
}
