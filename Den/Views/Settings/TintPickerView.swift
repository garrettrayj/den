//
//  TintPickerView.swift
//  Den
//
//  Created by Garrett Johnson on 3/2/23.
//  Copyright © 2023 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

struct TintPickerView: View {
    @Binding var tint: String?

    var body: some View {
        Picker(selection: $tint) {
            Label("None", systemImage: "hexagon")
                .foregroundColor(Color(.secondaryLabel))
                .padding(.vertical, 8)
                .tag(nil as String?)

            ForEach(TintOption.allCases, id: \.self) { tintOption in
                Label(tintOption.rawValue, systemImage: "hexagon.fill")
                    .foregroundColor(tintOption.color)
                    .padding(.vertical, 8)
                    .tag(tintOption.rawValue as String?)
            }
        } label: {
            Text("Tint").modifier(FormRowModifier())
        }
        .pickerStyle(.navigationLink)
        .accessibilityIdentifier("tint-picker")
    }
}
