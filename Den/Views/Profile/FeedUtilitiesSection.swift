//
//  FeedsUtilitiesSection.swift
//  Den
//
//  Created by Garrett Johnson on 8/11/22.
//  Copyright © 2022 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

struct FeedUtilitiesSection: View {
    var body: some View {
        Section(header: Text("Feeds")) {
            NavigationLink(value: ProfileSettingsPanel.importFeeds) {
                Text("Import")
            }
            .modifier(FormRowModifier())
            .accessibilityIdentifier("import-button")

            NavigationLink(value: ProfileSettingsPanel.exportFeeds) {
                Text("Export")
            }
            .modifier(FormRowModifier())
            .accessibilityIdentifier("export-button")

            NavigationLink(value: ProfileSettingsPanel.security) {
                Text("Security")
            }
            .modifier(FormRowModifier())
            .accessibilityIdentifier("security-check-button")
        }
        .modifier(ListRowModifier())
    }
}
