//
//  NewPageButton.swift
//  Den
//
//  Created by Garrett Johnson on 6/19/23.
//  Copyright © 2023 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

struct NewPageButton: View {
    @Binding var showingNewPageSheet: Bool

    var body: some View {
        Button {
            showingNewPageSheet = true
        } label: {
            Label {
                Text("New Page", comment: "Button label.")
            } icon: {
                Image(systemName: "folder.badge.plus")
            }
        }
        .keyboardShortcut("n", modifiers: [.command, .shift], localization: .withoutMirroring)
        .accessibilityIdentifier("NewPage")
    }
}
