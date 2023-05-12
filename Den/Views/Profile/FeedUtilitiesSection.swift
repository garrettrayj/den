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
    @ObservedObject var profile: Profile

    var body: some View {
        Section(header: Text("Feeds")) {
            NavigationLink(value: SubDetailPanel.importFeeds(profile)) {
                Text("Import")
            }
            .modifier(FormRowModifier())
            .accessibilityIdentifier("import-button")

            NavigationLink(value: SubDetailPanel.exportFeeds(profile)) {
                Text("Export")
            }
            .modifier(FormRowModifier())
            .accessibilityIdentifier("export-button")

            NavigationLink(value: SubDetailPanel.security(profile)) {
                Text("Security")
            }
            .modifier(FormRowModifier())
            .accessibilityIdentifier("security-check-button")
        }
        .modifier(ListRowModifier())
    }
}
