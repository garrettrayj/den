//
//  ShareButton.swift
//  Den
//
//  Created by Garrett Johnson on 6/18/23.
//  Copyright © 2023 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

struct ShareButton: View {

    let url: URL

    var body: some View {
        ShareLink(item: url) {
            Label {
                Text("Share…", comment: "Button label.")
            } icon: {
                Image(systemName: "square.and.arrow.up")
            }
        }
        .accessibilityIdentifier("share-button")
    }
}
