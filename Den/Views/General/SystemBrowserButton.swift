//
//  SystemBrowserButton.swift
//  Den
//
//  Created by Garrett Johnson on 1/1/24.
//  Copyright © 2024 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

struct SystemBrowserButton: View {
    @Environment(\.openURL) private var openURL
    
    let url: URL
    
    var body: some View {
        Button {
            openURL(url)
        } label: {
            Label {
                Text("Open Link", comment: "Button label.")
            } icon: {
                Image(systemName: "link.circle")
            }
        }
        .help(Text("Open in system browser", comment: "Button help text."))
        .accessibilityIdentifier("OpenInBrowser")
    }
}
