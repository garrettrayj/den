//
//  ToggleJavaScriptButton.swift
//  Den
//
//  Created by Garrett Johnson on 10/21/23.
//  Copyright © 2023 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

struct ToggleJavaScriptButton: View {
    @ObservedObject var browserViewModel: BrowserViewModel

    var body: some View {
        Button {
            Task {
                await browserViewModel.toggleJavaScript()
            }
        } label: {
            Label {
                if browserViewModel.allowJavaScript {
                    Text("Disable JavaScript", comment: "Button label.")
                } else {
                    Text("Enable JavaScript", comment: "Button label.")
                }
            } icon: {
                Image(systemName: "curlybraces")
            }
        }
    }
}
