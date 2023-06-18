//
//  GeneralSettingsTab.swift
//  Den
//
//  Created by Garrett Johnson on 6/14/23.
//  Copyright © 2023 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

struct GeneralSettingsTab: View {
    @Binding var activeProfile: Profile?
    @Binding var appProfileID: String?
    @Binding var userColorScheme: UserColorScheme

    var body: some View {
        Form {
            Section {
                UserColorSchemePicker(userColorScheme: $userColorScheme).pickerStyle(.segmented)
            } header: {
                Text("Appearance", comment: "Settings section header.")
            }
            
            
            Section {
                ClearCacheButton().buttonStyle(.borderless)
                
                ResetEverythingButton(
                    activeProfile: $activeProfile,
                    appProfileID: $appProfileID
                )
                .buttonStyle(.plain)
            } header: {
                Text("Reset", comment: "Settings section header.")
            }
            
            
        }
        .formStyle(.grouped)
    }
}
