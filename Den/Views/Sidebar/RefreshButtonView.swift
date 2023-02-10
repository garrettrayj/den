//
//  RefreshButtonView.swift
//  Den
//
//  Created by Garrett Johnson on 12/3/22.
//  Copyright © 2022 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

struct RefreshButtonView: View {
    @Environment(\.editMode) private var editMode

    let profile: Profile

    @Binding var refreshing: Bool

    var body: some View {
        if editMode?.wrappedValue == .inactive {
            Button {
                guard !refreshing else { return }
                Task {
                    await RefreshUtility.refresh(profile: profile)
                }
            } label: {
                Label("Refresh", systemImage: "arrow.clockwise")
            }
            .buttonStyle(PlainToolbarButtonStyle())
            .keyboardShortcut("r", modifiers: [.command])
            .accessibilityIdentifier("profile-refresh-button")
        }
    }
}
