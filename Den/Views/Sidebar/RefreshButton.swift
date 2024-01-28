//
//  RefreshButton.swift
//  Den
//
//  Created by Garrett Johnson on 12/3/22.
//  Copyright © 2022 Garrett Johnson
//
//  SPDX-License-Identifier: NONE
//

import SwiftUI

struct RefreshButton: View {
    var body: some View {
        Button {
            NotificationCenter.default.post(name: .refreshTriggered, object: nil)
        } label: {
            Label {
                Text("Refresh", comment: "Button label.")
            } icon: {
                Image(systemName: "arrow.clockwise")
            }
        }
        .keyboardShortcut("r", modifiers: [.command], localization: .withoutMirroring)
        .accessibilityIdentifier("Refresh")
    }
}
