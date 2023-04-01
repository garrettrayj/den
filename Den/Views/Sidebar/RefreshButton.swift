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
    @ObservedObject var profile: Profile

    @Binding var refreshing: Bool

    var body: some View {
        Button {
            Task {
                guard !refreshing else { return }
                await RefreshManager.refresh(profile: profile)
            }
        } label: {
            Label("Refresh", systemImage: "arrow.clockwise")
        }
        .buttonStyle(PlainToolbarButtonStyle())
        .accessibilityIdentifier("profile-refresh-button")
    }
}
