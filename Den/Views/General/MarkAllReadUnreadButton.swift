//
//  MarkAllReadUnreadButton.swift
//  Den
//
//  Created by Garrett Johnson on 11/13/22.
//  Copyright © 2022 Garrett Johnson
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
            if allRead {
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
        .disabled(toggling)
        .accessibilityIdentifier("ToggleRead")
    }
}
