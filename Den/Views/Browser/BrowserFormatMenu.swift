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
    @Bindable var browserViewModel: BrowserViewModel
    
    var body: some View {
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
                Text("Format", comment: "Button label.")
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
        .help(Text("Show Format Menu", comment: "Menu help text."))
        .accessibilityIdentifier("FormatMenu")
    }
}
