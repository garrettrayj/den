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

struct OpenInBrowserButton<Content: View>: View {
    @Environment(\.openURL) private var openURL
    @Environment(\.userTint) private var userTint
    @Environment(\.useSystemBrowser) private var useSystemBrowser

    let url: URL
    var readerMode: Bool?

    @ViewBuilder let label: Content

    var body: some View {
        if useSystemBrowser {
            Button {
                openURL(url)
            } label: {
                label
            }
        } else {
            NavigationLink {
                BrowserView(url: url, readerMode: readerMode)
            } label: {
                label
            }
        }
    }
}
