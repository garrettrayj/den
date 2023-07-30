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
            Label {
                Text("Mark All", comment: "Button label.")
            } icon: {
                if unreadCount == 0 {
                    Image(systemName: "checkmark.circle.fill")
                } else {
                    Image(systemName: "checkmark.circle")
                }
            }
        }
        .disabled(toggling)
        .accessibilityIdentifier("ToggleRead")

    }
}
