//
//  ToggleReadButton.swift
//  Den
//
//  Created by Garrett Johnson on 11/13/22.
//  Copyright © 2022 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

struct ToggleReadButton: View {
    let unreadCount: Int
    let toggleAll: () async -> Void

    @State private var toggling = false

    var body: some View {
        Button {
            toggling = true
            Task {
                await toggleAll()
                toggling = false
            }
        } label: {
            if toggling {
                ProgressView().progressViewStyle(CircularProgressViewStyle())
            } else if unreadCount == 0 {
                Label(
                    "Mark all unread",
                    systemImage: "checkmark.circle.fill"
                )
            } else {
                Label(
                    "Mark all read",
                    systemImage: "checkmark.circle"
                )
            }
        }
        .modifier(ToolbarButtonModifier())
        .accessibilityIdentifier("mark-all-read-button")
        .disabled(toggling)
    }
}
