//
//  UIStylePickerView.swift
//  Den
//
//  Created by Garrett Johnson on 3/1/23.
//  Copyright © 2023 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

struct UIStylePickerView: View {
    @Binding var uiStyle: UIUserInterfaceStyle

    var body: some View {
        Picker(selection: $uiStyle) {
            Text("System", comment: "Theme picker option.").tag(UIUserInterfaceStyle.unspecified)
            Text("Light", comment: "Theme picker option.").tag(UIUserInterfaceStyle.light)
            Text("Dark", comment: "Theme picker option.").tag(UIUserInterfaceStyle.dark)
        } label: {
            Text("Theme", comment: "Picker label.")
        }
        .accessibilityIdentifier("ui-style-picker")
    }
}
