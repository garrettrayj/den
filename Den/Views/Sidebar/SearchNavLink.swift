//
//  SearchNavLink.swift
//  Den
//
//  Created by Garrett Johnson on 12/17/23.
//  Copyright © 2023 Garrett Johnson
//

import SwiftUI

struct SearchNavLink: View {
    var body: some View {
        NavigationLink(value: DetailPanel.search) {
            Label {
                Text("Search")
            } icon: {
                Image(systemName: "magnifyingglass")
            }
        }
        .accessibilityIdentifier("SearchNavLink")
    }
}

