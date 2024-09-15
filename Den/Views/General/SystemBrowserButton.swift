//
//  SystemBrowserButton.swift
//  Den
//
//  Created by Garrett Johnson on 1/1/24.
//  Copyright © 2024 Garrett Johnson. All rights reserved.
//

import SwiftUI

struct SystemBrowserButton: View {
    @Environment(\.openURL) private var openURL
    
    let url: URL
    var callback: (() -> Void)?
    
    var body: some View {
        Button {
            openURL(url)
            callback?()
        } label: {
            Label {
                Text("Open in Browser", comment: "Button label.")
            } icon: {
                Image(systemName: "arrow.up.forward.app")
            }
        }
        .help(Text("Open in default web browser", comment: "Button help text."))
        .accessibilityIdentifier("OpenInWebBrowser")
    }
}
