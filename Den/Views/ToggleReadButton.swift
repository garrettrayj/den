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
        if toggling {
            ProgressView()
                #if os(macOS)
                .scaleEffect(0.5)
                .frame(width: 36)
                #else
                .frame(width: 26)
                #endif
        } else {
            Button {
                toggling = true
                Task {
                    await toggleAll()
                    toggling = false
                }
            } label: {
                if unreadCount == 0 {
                    Label {
                        Text("Mark All Unread", comment: "Button label.")
                    } icon: {
                        Image(systemName: "checkmark.circle.fill")
                    }
                } else {
                    Label {
                        Text("Mark All Read", comment: "Button label.")
                    } icon: {
                        Image(systemName: "checkmark.circle")
                    }
                }
            }
            .accessibilityIdentifier("toggle-read-button")
        }
    }
}
