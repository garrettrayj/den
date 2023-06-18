//
//  SettingsSheetResetSection.swift
//  Den
//
//  Created by Garrett Johnson on 8/11/22.
//  Copyright © 2022 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

import SDWebImage

struct SettingsSheetResetSection: View {
    @Binding var activeProfile: Profile?
    @Binding var appProfileID: String?

    var body: some View {
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
}
