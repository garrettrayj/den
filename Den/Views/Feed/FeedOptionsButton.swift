//
//  FeedOptionsButton.swift
//  Den
//
//  Created by Garrett Johnson on 6/17/23.
//  Copyright © 2023 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

struct FeedOptionsButton: View {
    @Binding var showingFeedOptions: Bool

    var body: some View {
        Button {
            Task {
                showingFeedOptions = true
            }
        } label: {
            Label {
                Text("Feed Options", comment: "Button label.")
            } icon: {
                Image(systemName: "slider.horizontal.3")
            }
        }
        .keyboardShortcut("j", modifiers: [.command], localization: .withoutMirroring)
        .accessibilityIdentifier("FeedOptions")
    }
}
