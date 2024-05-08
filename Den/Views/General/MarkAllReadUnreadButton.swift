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
                if allRead {
                    Text("Mark All Unread", comment: "Button label.")
                } else {
                    Text("Mark All Read", comment: "Button label.")
                }
            } icon: {
                Image(systemName: "checkmark.circle").symbolVariant(allRead ? .fill : .none)
            }
        }
        .disabled(toggling)
        .help(
            allRead ? Text("Mark All Unread", comment: "Button help text.") :
                Text("Mark All Read", comment: "Button help text.")
        )
        .accessibilityIdentifier("ToggleRead")
    }
}
