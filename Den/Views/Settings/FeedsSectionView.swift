//
//  FeedsSectionView.swift
//  Den
//
//  Created by Garrett Johnson on 8/11/22.
//  Copyright © 2022 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

struct FeedsSectionView: View {
    var body: some View {
        Section(header: Text("Feeds")) {
            NavigationLink(value: SettingsPanel.importFeeds) {
                Text("Import")
            }
            .modifier(FormRowModifier())
            .accessibilityIdentifier("import-button")

            NavigationLink(value: SettingsPanel.exportFeeds) {
                Text("Export")
            }
            .modifier(FormRowModifier())
            .accessibilityIdentifier("export-button")

            NavigationLink(value: SettingsPanel.security) {
                Text("Security")
            }
            .modifier(FormRowModifier())
            .accessibilityIdentifier("security-check-button")
        }
    }
}
