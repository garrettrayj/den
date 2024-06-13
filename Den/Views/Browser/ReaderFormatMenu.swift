//
//  ReaderFormatMenu.swift
//  Den
//
//  Created by Garrett Johnson on 10/20/23.
//  Copyright © 2023 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

struct ReaderFormatMenu: View {
    @Bindable var browserViewModel: BrowserViewModel
    
    var body: some View {
        Menu {
            ToggleReaderButton(browserViewModel: browserViewModel)
            ReaderZoom(browserViewModel: browserViewModel)
        } label: {
            Label {
                Text("Formatting", comment: "Button label.")
            } icon: {
                Image(systemName: "doc.plaintext.fill")
            }
        } primaryAction: {
            browserViewModel.toggleReader()
        }
        .help(Text("Show Reader Formatting", comment: "Menu help text."))
        .accessibilityIdentifier("ReaderFormat")
    }
}
