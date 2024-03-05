//
//  UserColorSchemePicker.swift
//  Den
//
//  Created by Garrett Johnson on 6/15/23.
//  Copyright © 2023 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

struct UserColorSchemePicker: View {
    @Binding var userColorScheme: UserColorScheme

    var body: some View {
        Picker(selection: $userColorScheme) {
            Text("System", comment: "User color scheme picker option.").tag(UserColorScheme.system)
            Text("Light", comment: "User color scheme picker option.").tag(UserColorScheme.light)
            Text("Dark", comment: "User color scheme picker option.").tag(UserColorScheme.dark)
        } label: {
            Label {
                Text("Appearance", comment: "Picker label.")
            } icon: {
                Image(systemName: "paintpalette")
            }
        }
    }
}
