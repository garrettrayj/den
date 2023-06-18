//
//  SettingsSheetRefreshSection.swift
//  Den
//
//  Created by Garrett Johnson on 11/5/22.
//  Copyright © 2022 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

struct SettingsSheetRefreshSection: View {
    @Binding var backgroundRefreshEnabled: Bool

    var body: some View {
        Section {
            Toggle(isOn: $backgroundRefreshEnabled) {
                Text("In Background", comment: "Refresh option toggle label.")
            }
        } header: {
            Text("Refresh", comment: "Setting section header.")
        }
        .modifier(ListRowModifier())
    }
}
