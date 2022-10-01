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
                Text("Import")
            }
            .modifier(FormRowModifier())
            .accessibilityIdentifier("import-button")

            NavigationLink(value: DetailPanel.exportFeeds) {
                Text("Export")
            }
            .modifier(FormRowModifier())
            .accessibilityIdentifier("export-button")

            NavigationLink(value: DetailPanel.security) {
                Text("Security")
            }
            .modifier(FormRowModifier())
            .accessibilityIdentifier("security-check-button")
        }
    }
}
