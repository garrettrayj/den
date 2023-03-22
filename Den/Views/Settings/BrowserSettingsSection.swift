//
//  BrowserSettingsSection.swift
//  Den
//
//  Created by Garrett Johnson on 12/31/22.
//  Copyright © 2022 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

struct BrowserSettingsSection: View {
    @ObservedObject var profile: Profile

    @Binding var useInbuiltBrowser: Bool

    var body: some View {
        Section {
            Toggle(isOn: $useInbuiltBrowser) {
                Text("Use Built-in Browser").modifier(FormRowModifier())
            }
        } header: {
            Text("Links")
        }
    }
}
