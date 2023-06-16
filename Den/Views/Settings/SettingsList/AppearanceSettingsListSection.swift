//
//  AppearanceSettingsListSection.swift
//  Den
//
//  Created by Garrett Johnson on 6/15/23.
//  Copyright © 2023 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

struct AppearanceSettingsListSection: View {
    @Binding var userColorScheme: UserColorScheme
    
    var body: some View {
        Section {
            UserColorSchemePicker(userColorScheme: $userColorScheme)
        } header: {
            Text("Appearance", comment: "Settings section header.")
        }
        .modifier(ListRowModifier())
    }
}
