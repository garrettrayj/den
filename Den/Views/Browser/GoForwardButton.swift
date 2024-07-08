//
//  GoForwardButton.swift
//  Den
//
//  Created by Garrett Johnson on 10/19/23.
//  Copyright © 2023 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

struct GoForwardButton: View {
    @Bindable var browserViewModel: BrowserViewModel

    var body: some View {
        Button {
            browserViewModel.goForward()
        } label: {
            Label {
                Text("Forward", comment: "Button label.")
            } icon: {
                Image(systemName: "chevron.forward")
            }
        }
        .disabled(!browserViewModel.canGoForward)
        .help(Text("Show Next Page", comment: "Button help text."))
        .accessibilityIdentifier("BrowserGoForward")
    }
}
