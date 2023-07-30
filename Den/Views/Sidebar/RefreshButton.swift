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
    @Environment(\.displayScale) private var displayScale
    @Environment(\.refresh) private var refresh

    @Binding var refreshing: Bool

    let refreshProgress: Progress

    var body: some View {
        if let refresh = refresh {
            Button {
                Task {
                    await refresh()
                }
            } label: {
                Label {
                    Text("Refresh", comment: "Button label.")
                } icon: {
                    #if os(macOS)
                    if refreshing {
                        ProgressView(refreshProgress)
                            .progressViewStyle(.circular)
                            .labelsHidden()
                            .scaleEffect(1 / displayScale)
                            .frame(width: 18)
                    } else {
                        Image(systemName: "arrow.clockwise")
                    }
                    #else
                    Image(systemName: "arrow.clockwise")
                    #endif
                }
            }
            .keyboardShortcut("r", modifiers: [.command], localization: .withoutMirroring)
            .accessibilityIdentifier("Refresh")
        }
    }
}
