//
//  RefreshSettingsSection.swift
//  Den
//
//  Created by Garrett Johnson on 11/5/22.
//  Copyright © 2022 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

struct RefreshSettingsSection: View {
    @Binding var autoRefreshEnabled: Bool
    @Binding var autoRefreshCooldown: Int
    @Binding var backgroundRefreshEnabled: Bool

    var body: some View {
        Section {
            #if os(macOS)
            HStack {
                Text("In Background").modifier(FormRowModifier())
                Spacer()
                Toggle(isOn: $backgroundRefreshEnabled) {
                    Text("In Background")
                }.labelsHidden()
            }
            #else
            Toggle(isOn: $backgroundRefreshEnabled) {
                Text("In Background", comment: "Refresh option toggle label.").modifier(FormRowModifier())
            }
            #endif

            #if os(macOS)
            HStack {
                Text("When Activated").modifier(FormRowModifier())
                Spacer()
                Toggle(isOn: $autoRefreshEnabled) {
                    Text("When Activated")
                }.labelsHidden()
            }
            #else
            Toggle(isOn: $autoRefreshEnabled) {
                Text("When Activated", comment: "Refresh option toggle label.").modifier(FormRowModifier())
            }
            #endif

            if autoRefreshEnabled {
                Stepper(
                    value: $autoRefreshCooldown,
                    in: 10...24 * 60,
                    step: autoRefreshCooldown >= 120 ? 60 : 10
                ) {
                    HStack {
                        Text(verbatim: "- ")
                        if autoRefreshCooldown >= 120 {
                            Text(
                                "Recovery Period: \(String(format: "%g", Float(autoRefreshCooldown) / 60)) hours",
                                comment: "Stepper label."
                            )
                                .font(.callout)
                                .modifier(FormRowModifier())
                        } else {
                            Text(
                                "Recovery Period: \(autoRefreshCooldown) minutes",
                                comment: "Stepper label."
                            )
                                .font(.callout)
                                .modifier(FormRowModifier())
                        }
                    }
                }
            }
        } header: {
            Text("Refresh", comment: "Setting section header.")
        }
        .modifier(ListRowModifier())
    }
}
