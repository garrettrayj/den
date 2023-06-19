//
//  OpenInBrowserButton.swift
//  Den
//
//  Created by Garrett Johnson on 6/18/23.
//  Copyright © 2023 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

struct OpenInBrowserButton: View {
    @Environment(\.openURL) private var openURL
    @Environment(\.profileTint) private var profileTint
    @Environment(\.useSystemBrowser) private var useSystemBrowser

    let url: URL
    var readerMode = false

    var body: some View {
        Button {
            #if os(macOS)
            openURL(url)
            #else
            if useSystemBrowser {
                openURL(url)
            } else {
                SafariUtility.openLink(
                    url: url,
                    controlTintColor: profileTint,
                    readerMode: readerMode
                )
            }
            #endif
        } label: {
            OpenInBrowserLabel()
        }
        .accessibilityIdentifier("open-in-browser-button")
    }
}
