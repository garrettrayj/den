//
//  GoForwardButton.swift
//  Den
//
//  Created by Garrett Johnson on 10/19/23.
//  Copyright © 2023 Garrett Johnson. All rights reserved.
//

import SwiftUI

struct GoForwardButton: View {
    @ObservedObject var browserViewModel: BrowserViewModel

    var body: some View {
        Button {
            browserViewModel.goForward()
        } label: {
            Label {
                Text("Go Forward", comment: "Button label.")
            } icon: {
                Image(systemName: "chevron.forward")
            }
        }
        .disabled(!browserViewModel.canGoForward)
        .help(Text("Show next page", comment: "Button help text."))
        .accessibilityIdentifier("BrowserGoForward")
    }
}
