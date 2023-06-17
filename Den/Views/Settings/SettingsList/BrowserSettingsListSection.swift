//
//  BrowserSettingsListSection.swift
//  Den
//
//  Created by Garrett Johnson on 12/31/22.
//  Copyright © 2022 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

struct BrowserSettingsListSection: View {
    @Binding var useSystemBrowser: Bool

    var body: some View {
        Section {
            Toggle(isOn: $useSystemBrowser) {
                Text("Use System Web Browser", comment: "Toggle label.")
            }
        } header: {
            Text("Links", comment: "Settings section header.")
        }
        .modifier(ListRowModifier())
    }
}
