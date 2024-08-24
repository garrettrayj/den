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
    @Environment(\.self) private var environment
    
    let url: URL
    let entersReaderIfAvailable: Bool
    var callback: (() -> Void)?
    
    @AppStorage("AccentColor") private var accentColor: AccentColor = .coral
    
    var body: some View {
        Button {
            InAppSafari.open(
                url: url,
                environment: environment,
                accentColor: accentColor,
                entersReaderIfAvailable: entersReaderIfAvailable
            )
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
