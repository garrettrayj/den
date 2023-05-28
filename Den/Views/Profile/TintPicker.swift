//
//  TintPicker.swift
//  Den
//
//  Created by Garrett Johnson on 3/2/23.
//  Copyright © 2023 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

struct TintPicker: View {
    @Binding var tint: String?

    var body: some View {
        Picker(selection: $tint) {
            Label {
                Text("None")
            } icon: {
                Image(systemName: "hexagon.fill")
            }
            .foregroundColor(.secondary)
            .modifier(FormRowModifier())
            .tag(nil as String?)

            ForEach(TintOption.allCases, id: \.self) { tintOption in
                Label(tintOption.rawValue, systemImage: "hexagon.fill")
                    .foregroundColor(tintOption.color)
                    .modifier(FormRowModifier())
                    .tag(tintOption.rawValue as String?)
            }
        } label: {
            Text("Tint").modifier(FormRowModifier())
        }
        .scrollContentBackground(.visible)
        .pickerStyle(.navigationLink)
        .accessibilityIdentifier("tint-picker")
    }
}
