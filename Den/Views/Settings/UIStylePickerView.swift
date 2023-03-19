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
            Text("System").tag(UIUserInterfaceStyle.unspecified)
            Text("Light").tag(UIUserInterfaceStyle.light)
            Text("Dark").tag(UIUserInterfaceStyle.dark)
        } label: {
            Text("Theme")
        }
        .accessibilityIdentifier("ui-style-picker")
    }
}
