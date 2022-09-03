//
//  FeedsSectionView.swift
//  Den
//
//  Created by Garrett Johnson on 8/11/22.
//  Copyright © 2022 Garrett Johnson. All rights reserved.
//

import SwiftUI

struct FeedsSectionView: View {
    let profile: Profile

    var body: some View {
        Section(header: Text("Feeds")) {
            NavigationLink(value: DetailPanel.importFeeds) {
                Label("Import", systemImage: "arrow.down.doc")
            }
            .modifier(FormRowModifier())
            .accessibilityIdentifier("import-button")

            NavigationLink(value: DetailPanel.exportFeeds) {
                Label("Export", systemImage: "arrow.up.doc")
            }
            .modifier(FormRowModifier())
            .accessibilityIdentifier("export-button")

            NavigationLink(value: DetailPanel.security) {
                Label("Security", systemImage: "shield.lefthalf.filled")
            }
            .modifier(FormRowModifier())
            .accessibilityIdentifier("security-check-button")
        }
    }
}
