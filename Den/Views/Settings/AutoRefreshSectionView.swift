//
//  AutoRefreshSectionView.swift
//  Den
//
//  Created by Garrett Johnson on 11/5/22.
//  Copyright © 2022 Garrett Johnson. All rights reserved.
//

import SwiftUI

struct AutoRefreshSectionView: View {
    @Binding var autoRefreshEnabled: Bool
    @Binding var autoRefreshCooldown: Int
    @Binding var backgroundRefreshEnabled: Bool

    var body: some View {
        Section {
            #if targetEnvironment(macCatalyst)
            HStack {
                Text("In Background")
                Spacer()
                Toggle(isOn: $backgroundRefreshEnabled) {
                    Text("In Background")
                }.labelsHidden()
            }
            .font(.body)
            .modifier(FormRowModifier())
            #else
            Toggle(isOn: $backgroundRefreshEnabled) {
                Text("In Background")
            }
            #endif

            #if targetEnvironment(macCatalyst)
            HStack {
                Text("When Activated")
                Spacer()
                Toggle(isOn: $autoRefreshEnabled) {
                    Text("When Activated")
                }.labelsHidden()
            }
            .font(.body)
            .modifier(FormRowModifier())
            #else
            Toggle(isOn: $autoRefreshEnabled) {
                Text("When Activated")
            }
            #endif

            if autoRefreshEnabled {
                Stepper(
                    value: $autoRefreshCooldown,
                    in: 10...24 * 60,
                    step: autoRefreshCooldown >= 120 ? 60 : 10
                ) {
                    if autoRefreshCooldown >= 120 {
                        Text("⁃ Cooldown: \(String(format: "%g", Float(autoRefreshCooldown) / 60)) hours")
                    } else {
                        Text("⁃ Cooldown: \(autoRefreshCooldown) minutes")
                    }

                }
                .font(.body)
                .modifier(FormRowModifier())
            }
        } header: {
            Text("Refresh")
        }
    }
}
