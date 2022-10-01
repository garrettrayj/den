//
//  TouchSectionView.swift
//  Den
//
//  Created by Garrett Johnson on 9/29/22.
//  Copyright © 2022 Garrett Johnson. All rights reserved.
//

import SwiftUI

struct TouchSectionView: View {
    @EnvironmentObject private var haptics: Haptics
    @Binding var hapticsEnabled: Bool
    @Binding var hapticsTapStyle: HapticsMode
    @State var hapticsModeSliderValue = 0.0

    var body: some View {
        Section(header: Text("Touch")) {
            Toggle(isOn: $hapticsEnabled) {
                Text("Haptics")
            }

            Picker(selection: $hapticsTapStyle) {
                Text("Off").tag(HapticsMode.off)
                Text("Light").tag(HapticsMode.light)
                Text("Medium").tag(HapticsMode.medium)
                Text("Heavy").tag(HapticsMode.heavy)
            } label: {
                Text("Tap Feedback").lineLimit(1)
            }.disabled(!hapticsEnabled)
        }
    }
}
