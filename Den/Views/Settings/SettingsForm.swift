//
//  SettingsForm.swift
//  Den
//
//  Created by Garrett Johnson on 6/14/23.
//  Copyright © 2023 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

struct SettingsForm: View {
    @Binding var userColorScheme: UserColorScheme
    @Binding var useSystemBrowser: Bool

    var body: some View {
        Form {
            Section {
                UserColorSchemePicker(userColorScheme: $userColorScheme).pickerStyle(.segmented)
                Toggle(isOn: $useSystemBrowser) {
                    Text("Use System Browser", comment: "Toggle label.")
                }
            } header: {
                Text("General", comment: "Settings section header.")
            }

            Section {
                ClearImageCacheButton().buttonStyle(.plain)
                ResetEverythingButton().buttonStyle(.plain)
            } header: {
                Text("Reset", comment: "Settings section header.")
            }
        }
        .formStyle(.grouped)
        .frame(width: 400, height: 300)
        .navigationTitle(Text("Settings", comment: "Navigation title."))
    }
}
