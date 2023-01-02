//
//  ToggleReadButtonView.swift
//  Den
//
//  Created by Garrett Johnson on 11/13/22.
//  Copyright © 2022 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

struct ToggleReadButtonView: View {
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
                    "Mark All Unread",
                    systemImage: "checkmark.circle.fill"
                )
            } else {
                Label(
                    "Mark All Read",
                    systemImage: "checkmark.circle"
                )
            }
        }
        .buttonStyle(PlainToolbarButtonStyle())
        .accessibilityIdentifier("mark-all-read-button")
        .disabled(toggling)
    }
}
