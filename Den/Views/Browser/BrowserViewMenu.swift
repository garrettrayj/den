//
//  BrowserViewMenu.swift
//  Den
//
//  Created by Garrett Johnson on 10/19/23.
//  Copyright © 2023 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

struct BrowserViewMenu: View {
    @Bindable var browserViewModel: BrowserViewModel
    
    var body: some View {
        Group {
            if browserViewModel.isReaderable {
                Menu {
                    ToggleReaderButton(browserViewModel: browserViewModel)

                    if browserViewModel.showingReader {
                        ReaderZoom(browserViewModel: browserViewModel)
                    } else {
                        ToggleBlocklistsButton(browserViewModel: browserViewModel)
                        ToggleJavaScriptButton(browserViewModel: browserViewModel)
                        #if os(macOS)
                        BrowserZoom(browserViewModel: browserViewModel)
                        #endif
                    }
                } label: {
                    Label {
                        Text("View", comment: "Button label.")
                    } icon: {
                        Image(systemName: "doc.plaintext")
                            .symbolVariant(browserViewModel.showingReader ? .fill : .none)
                    }
                } primaryAction: {
                    withAnimation {
                        browserViewModel.toggleReader()
                    }
                }
                .contentTransition(.symbolEffect(.replace))
                .help(Text("Show browser view settings", comment: "Menu help text."))
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
                .help(Text("Show browser view settings", comment: "Menu help text."))
            }
        }
        .accessibilityIdentifier("BrowserViewSettings")
    }
}
