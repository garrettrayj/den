//
//  RefreshButton.swift
//  Den
//
//  Created by Garrett Johnson on 12/3/22.
//  Copyright © 2022 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

struct RefreshButton: View {
    @EnvironmentObject private var refreshManager: RefreshManager

    @Binding var activeProfile: Profile?

    var body: some View {
        Button {
            Task {
                guard let profile = activeProfile else { return }
                await refreshManager.refresh(profile: profile)
            }
        } label: {
            Label {
                Text("Refresh", comment: "Button label.")
            } icon: {
                Image(systemName: "arrow.clockwise")
            }
        }
        .keyboardShortcut("r", modifiers: [.command])
        .accessibilityIdentifier("refresh-button")
    }
}
