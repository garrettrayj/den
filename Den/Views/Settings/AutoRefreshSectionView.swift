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
                    Text("When Actived")
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
                HStack(spacing: 4) {
                    Text("⁃ Cooldown:")
                    TimeIntervalPickerView(
                        duration: $autoRefreshCooldown,
                        minimum: 60,
                        maximum: 7 * 24 * 60 * 60
                    )
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
