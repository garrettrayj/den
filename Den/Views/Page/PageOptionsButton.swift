//
//  PageOptionsButton.swift
//  Den
//
//  Created by Garrett Johnson on 6/17/23.
//  Copyright © 2023 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

struct PageOptionsButton: View {
    @Binding var showingPageOptions: Bool

    var body: some View {
        Button {
            showingPageOptions = true
        } label: {
            Label {
                Text("Page Options", comment: "Button label.")
            } icon: {
                Image(systemName: "slider.horizontal.3")
            }
        }
        .keyboardShortcut("j", modifiers: [.command], localization: .withoutMirroring)
        .accessibilityIdentifier("PageOptions")
    }
}
