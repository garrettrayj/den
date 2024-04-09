//
//  LookAndFeelSection.swift
//  Den
//
//  Created by Garrett Johnson on 6/14/23.
//  Copyright © 2023 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

struct LookAndFeelSection: View {
    @Binding var accentColor: AccentColor?
    @Binding var userColorScheme: UserColorScheme
    @Binding var useSystemBrowser: Bool

    var body: some View {
        Section {
            UserColorSchemePicker(userColorScheme: $userColorScheme)
            AccentColorSelector(selection: $accentColor)
            Toggle(isOn: $useSystemBrowser) {
                Label {
                    Text("Use System Browser", comment: "Toggle label.")
                } icon: {
                    Image(systemName: "arrow.up.right.square")
                }
            }
        } header: {
            Text("Look & Feel", comment: "Settings section header.")
        }
    }
}
