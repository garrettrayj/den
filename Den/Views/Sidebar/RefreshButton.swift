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

    @ObservedObject var profile: Profile

    var body: some View {
        Button {
            Task {
                await refreshManager.refresh(profile: profile)
            }
        } label: {
            Label("Refresh", systemImage: "arrow.clockwise")
        }
        .modifier(ToolbarButtonModifier())
        .accessibilityIdentifier("profile-refresh-button")
    }
}
