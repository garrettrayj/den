//
//  ToggleJavaScriptButton.swift
//  Den
//
//  Created by Garrett Johnson on 10/21/23.
//  Copyright © 2023 Garrett Johnson
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
            if browserViewModel.allowJavaScript {
                Label {
                    Text("Disable JavaScript", comment: "Button label.")
                } icon: {
                    Image(systemName: "curlybraces")
                }
            } else {
                Label {
                    Text("Enable JavaScript", comment: "Button label.")
                } icon: {
                    Image(systemName: "curlybraces")
                }
            }
        }
    }
}
