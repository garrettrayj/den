//
//  RefreshButton.swift
//  Den
//
//  Created by Garrett Johnson on 12/3/22.
//  Copyright © 2022 Garrett Johnson
//

import SwiftUI

struct RefreshButton: View {
    @Environment(\.displayScale) private var displayScale

    @ObservedObject var profile: Profile

    @Binding var refreshing: Bool
    @Binding var refreshProgress: Progress

    var body: some View {
        Button {
            Task {
                await RefreshManager.refresh(profile: profile)
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
