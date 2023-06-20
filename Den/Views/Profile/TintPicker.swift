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
    @Binding var tintSelection: TintOption?

    var body: some View {
        Picker(selection: $tintSelection) {
            Label {
                Text("No Tint", comment: "Tint color option.")
            } icon: {
                Image(systemName: "hexagon.fill")
            }
            .foregroundColor(.secondary)
            .tag(nil as TintOption?)

            ForEach(TintOption.allCases, id: \.self) { tintOption in
                Label {
                    tintOption.labelText
                } icon: {
                    Image(systemName: "hexagon.fill")
                }
                .foregroundColor(tintOption.color)
                .tag(tintOption as TintOption?)
            }
        } label: {
            Text("Custom Tint", comment: "Picker label.").frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.vertical, 4)
        .tint(tintSelection?.color)
        .scrollContentBackground(.visible)
        #if os(iOS)
        .pickerStyle(.navigationLink)
        #endif
        .accessibilityIdentifier("tint-picker")
    }
}
