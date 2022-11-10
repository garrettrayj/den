//
//  AutoRefreshSectionView.swift
//  Den
//
//  Created by Garrett Johnson on 11/5/22.
//  Copyright © 2022 Garrett Johnson. All rights reserved.
//

import SwiftUI

struct AutoRefreshSectionView: View {
    @EnvironmentObject var haptics: Haptics
    
    @Binding var autoRefreshEnabled: Bool
    @Binding var autoRefreshCooldown: Int
    @Binding var backgroundRefreshEnabled: Bool

    var body: some View {
        Section {
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
                    in: 5...24 * 60,
                    step: autoRefreshCooldown >= 90 ? 30 : 5
                ) {
                    if autoRefreshCooldown >= 90 {
                        Text("⁃ Cooldown: \(String(format: "%g", Float(autoRefreshCooldown) / 60)) hours")
                    } else {
                        Text("⁃ Cooldown: \(autoRefreshCooldown) minutes")
                    }
                    
                }
                .font(.body)
                .modifier(FormRowModifier())
            }
            
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
        } header: {
            Text("Refresh")
        }
    }
}
