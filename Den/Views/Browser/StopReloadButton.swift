//
//  StopReloadButton.swift
//  Den
//
//  Created by Garrett Johnson on 10/19/23.
//  Copyright © 2023 Garrett Johnson. All rights reserved.
//

import SwiftUI

struct StopReloadButton: View {
    @ObservedObject var browserViewModel: BrowserViewModel
    
    var body: some View {
        if browserViewModel.isLoading {
            Button {
                browserViewModel.stop()
            } label: {
                Label {
                    Text("Stop", comment: "Button label.")
                } icon: {
                    Image(systemName: "xmark")
                }
            }
            .help(Text("Stop loading page", comment: "Button help text."))
            .accessibilityIdentifier("BrowserStop")
        } else {
            Button {
                browserViewModel.reload()
            } label: {
                Label {
                    Text("Reload", comment: "Button label.")
                } icon: {
                    Image(systemName: "arrow.clockwise")
                }
            }
            .keyboardShortcut("r", modifiers: [.control, .command])
            .help(Text("Reload page", comment: "Button help text."))
            .accessibilityIdentifier("BrowserReload")
        }
    }
}
