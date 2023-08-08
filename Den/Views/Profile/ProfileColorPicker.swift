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
            Label {
                Text("Default", comment: "Profile color option.")
            } icon: {
                Image(systemName: "paintbrush")
            }
            .foregroundStyle(.secondary)
            .tag(nil as ProfileColorOption?)

            ForEach(ProfileColorOption.allCases, id: \.self) { option in
                Label {
                    option.labelText
                } icon: {
                    Image(systemName: "paintbrush.fill")
                }
                .foregroundStyle(option.color)
                .tag(option as ProfileColorOption?)
            }
        } label: {
            Label {
                Text("Color", comment: "Picker label.").frame(maxWidth: .infinity, alignment: .leading)
            } icon: {
                Image(systemName: "paintpalette")
            }
        }
        #if os(iOS)
        .pickerStyle(.navigationLink)
        #endif
        .tint(selection?.color)
        .accessibilityIdentifier("ProfileColorPicker")
    }
}
