//
//  InAppSafariButton.swift
//  Den
//
//  Created by Garrett Johnson on 8/22/24.
//  Copyright © 2024 
//
//  SPDX-License-Identifier: MIT
//

#if os(iOS)
import SwiftUI

struct SafariViewButton: View {
    @Environment(\.openURLInSafariView) private var openURLInSafariView
    
    let url: URL
    var entersReaderIfAvailable: Bool?
    var callback: (() -> Void)?
    
    var body: some View {
        Button {
            openURLInSafariView(url, entersReaderIfAvailable)
            callback?()
        } label: {
            Label {
                Text("Open in Safari View", comment: "Button label.")
            } icon: {
                Image(systemName: "safari")
            }
        }
        .help(Text("Open in Safari view", comment: "Button help text."))
        .accessibilityIdentifier("OpenInSafariView")
    }
}
#endif
