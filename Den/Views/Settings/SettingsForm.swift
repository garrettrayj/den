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
    @Binding var feedRefreshTimeout: Int
    @Binding var userColorScheme: UserColorScheme

    var body: some View {
        Form {
            Section {
                UserColorSchemePicker(userColorScheme: $userColorScheme).pickerStyle(.segmented)
                FeedRefreshTimeoutSlider(feedRefreshTimeout: $feedRefreshTimeout)
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
        .frame(minWidth: 400, maxWidth: 500, minHeight: 360, maxHeight: 400)
        .navigationTitle(Text("Settings", comment: "Navigation title."))
    }
}
