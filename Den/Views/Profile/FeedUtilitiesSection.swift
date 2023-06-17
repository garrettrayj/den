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
        Section(header: Text("Feeds", comment: "Profile settings section header.")) {
            NavigationLink(value: SubDetailPanel.importFeeds(profile)) {
                Text("Import", comment: "Button label.")
            }
            
            .accessibilityIdentifier("import-button")

            NavigationLink(value: SubDetailPanel.exportFeeds(profile)) {
                Text("Export", comment: "Button label.")
            }
            
            .accessibilityIdentifier("export-button")

            NavigationLink(value: SubDetailPanel.security(profile)) {
                Text("Security", comment: "Button label.")
            }
            
            .accessibilityIdentifier("security-check-button")
        }
        .modifier(ListRowModifier())
    }
}
