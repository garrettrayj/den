//
//  RefreshButtonView.swift
//  Den
//
//  Created by Garrett Johnson on 12/3/22.
//  Copyright © 2022 Garrett Johnson. All rights reserved.
//

import SwiftUI

struct RefreshButtonView: View {
    @Environment(\.persistentContainer) private var container
    @Environment(\.editMode) private var editMode

    let profile: Profile

    var body: some View {
        if editMode?.wrappedValue == .inactive {
            Button {
                Task {
                    await RefreshUtility.refresh(container: container, profile: profile)
                }
            } label: {
                Label("Refresh", systemImage: "arrow.clockwise")
            }
            .buttonStyle(ToolbarButtonStyle())
            .keyboardShortcut("r", modifiers: [.command])
            .accessibilityIdentifier("profile-refresh-button")
        }
    }
}
