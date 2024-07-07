//
//  StopReloadButton.swift
//  Den
//
//  Created by Garrett Johnson on 10/19/23.
//  Copyright © 2023 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

struct StopReloadButton: View {
    @Bindable var browserViewModel: BrowserViewModel
    
    var body: some View {
        Button {
            if browserViewModel.isLoading {
                browserViewModel.stop()
            } else {
                browserViewModel.reload()
            }
        } label: {
            Label {
                Text("Stop/Reload", comment: "Button label.")
            } icon: {
                if browserViewModel.isLoading {
                    Image(systemName: "xmark")
                } else {
                    Image(systemName: "arrow.clockwise")
                }
            }
        }
        .help(Text("Stop/Reload", comment: "Button help text."))
        .accessibilityIdentifier("StopReloadButton")
    }
}
