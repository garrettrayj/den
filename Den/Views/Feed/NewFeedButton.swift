//
//  NewFeedButton.swift
//  Den
//
//  Created by Garrett Johnson on 12/3/22.
//  Copyright © 2022 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

struct NewFeedButton: View {
    @Binding var showingNewFeedSheet: Bool

    var body: some View {
        Button {
            showingNewFeedSheet = true
        } label: {
            Label {
                Text("New Feed", comment: "Button label.")
            } icon: {
                Image(systemName: "note.text.badge.plus")
            }
        }
        .keyboardShortcut("n", modifiers: [.command], localization: .withoutMirroring)
        .accessibilityIdentifier("NewFeed")
    }
}
