//
//  ProfileColorPicker.swift
//  Den
//
//  Created by Garrett Johnson on 3/2/23.
//  Copyright © 2023 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

struct ProfileColorPicker: View {
    @Binding var selection: ProfileColorOption?

    var body: some View {
        Picker(selection: $selection) {
            Text("Default", comment: "Profile color option.")
                .foregroundStyle(.secondary)
                .tag(nil as ProfileColorOption?)

            ForEach(ProfileColorOption.allCases, id: \.self) { option in
                option.labelText
                    .foregroundStyle(option.color)
                    .tag(option as ProfileColorOption?)
            }
        } label: {
            Label {
                Text("Color", comment: "Picker label.").frame(maxWidth: .infinity, alignment: .leading)
            } icon: {
                if let selection = selection {
                    Image(systemName: "paintbrush.fill").foregroundStyle(selection.color)
                } else {
                    Image(systemName: "paintbrush")
                }
            }
        }
        .tint(selection?.color)
        .scrollContentBackground(.visible)
        .accessibilityIdentifier("ProfileColorPicker")
    }
}
