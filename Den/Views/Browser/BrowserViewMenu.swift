//
//  BrowserFormatMenu.swift
//  Den
//
//  Created by Garrett Johnson on 10/19/23.
//  Copyright © 2023 Garrett Johnson. All rights reserved.
//

import SwiftUI

struct BrowserViewMenu: View {
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
                        Text("View", comment: "Button label.")
                    } icon: {
                        Image(systemName: "doc.plaintext")
                    }
                } primaryAction: {
                    browserViewModel.toggleReader()
                }
                .help(Text("Show reader", comment: "Menu help text."))
            } else {
                Menu {
                    ToggleBlocklistsButton(browserViewModel: browserViewModel)
                    ToggleJavaScriptButton(browserViewModel: browserViewModel)
                    #if os(macOS)
                    BrowserZoom(browserViewModel: browserViewModel)
                    #endif
                } label: {
                    Label {
                        Text("View", comment: "Button label.")
                    } icon: {
                        Image(systemName: "textformat.size")
                    }
                }
                .help(Text("Show browser view options", comment: "Menu help text."))
            }
        }
        .accessibilityIdentifier("BrowserViewMenu")
    }
}
