//
//  MarkAllReadUnreadButton.swift
//  Den
//
//  Created by Garrett Johnson on 11/13/22.
//  Copyright © 2022 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

struct MarkAllReadUnreadButton: View {
    let allRead: Bool
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
                Image(systemName: "checkmark.circle").symbolVariant(allRead ? .fill : .none)
            }
        }
        .disabled(toggling)
        .accessibilityIdentifier("ToggleRead")
    }
}
