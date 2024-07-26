//
//  AppearanceSection.swift
//  Den
//
//  Created by Garrett Johnson on 6/2/24.
//  Copyright © 2024 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI
import WidgetKit

struct AppearanceSection: View {
    @AppStorage("AccentColor") private var accentColor: AccentColor = .coral
    @AppStorage("UserColorScheme") private var userColorScheme: UserColorScheme = .system
    
    var body: some View {
        Section {
            UserColorSchemePicker(userColorScheme: $userColorScheme)
            AccentColorSelector(selection: $accentColor)
        } header: {
            Text("Appearance", comment: "Settings section header.")
        }
        .onChange(of: accentColor) {
            UserDefaults.group.set(accentColor.rawValue, forKey: "AccentColor")
            WidgetCenter.shared.reloadAllTimelines()
        }
    }
}
