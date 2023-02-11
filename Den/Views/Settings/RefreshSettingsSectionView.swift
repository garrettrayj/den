//
//  RefreshSettingsSectionView.swift
//  Den
//
//  Created by Garrett Johnson on 11/5/22.
//  Copyright © 2022 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

struct RefreshSettingsSectionView: View {
    @Binding var autoRefreshEnabled: Bool
    @Binding var autoRefreshCooldown: Int
    @Binding var backgroundRefreshEnabled: Bool

    var body: some View {
        Section {
            #if targetEnvironment(macCatalyst)
            HStack {
                Text("In Background").modifier(FormRowModifier())
                Spacer()
                Toggle(isOn: $backgroundRefreshEnabled) {
                    Text("In Background")
                }.labelsHidden()
            }
            #else
            Toggle(isOn: $backgroundRefreshEnabled) {
                Text("In Background").modifier(FormRowModifier())
            }
            #endif

            #if targetEnvironment(macCatalyst)
            HStack {
                Text("When Activated").modifier(FormRowModifier())
                Spacer()
                Toggle(isOn: $autoRefreshEnabled) {
                    Text("When Activated")
                }.labelsHidden()
            }
            #else
            Toggle(isOn: $autoRefreshEnabled) {
                Text("When Activated").modifier(FormRowModifier())
            }
            #endif

            if autoRefreshEnabled {
                Stepper(
                    value: $autoRefreshCooldown,
                    in: 10...24 * 60,
                    step: autoRefreshCooldown >= 120 ? 60 : 10
                ) {
                    Group {
                        if autoRefreshCooldown >= 120 {
                            Text("⁃ Cooldown: \(String(format: "%g", Float(autoRefreshCooldown) / 60)) hours")
                        } else {
                            Text("⁃ Cooldown: \(autoRefreshCooldown) minutes")
                        }
                    }.modifier(FormRowModifier())
                }
            }
        } header: {
            Text("Refresh")
        }
    }
}
