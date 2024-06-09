//
//  BlocklistsSection.swift
//  Den
//
//  Created by Garrett Johnson on 10/13/23.
//  Copyright © 2023 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftData
import SwiftUI

struct BlocklistsSection: View {
    @Query(sort: [SortDescriptor(\Blocklist.name, order: .forward)])
    private var blocklists: [Blocklist]

    var body: some View {
        Section {
            ForEach(blocklists) { blocklist in
                NavigationLink {
                    BlocklistSettings(blocklist: blocklist)
                        .navigationTitle(blocklist.nameText)
                        .toolbarTitleDisplayMode(.inline)
                } label: {
                    Label {
                        VStack(alignment: .leading) {
                            blocklist.nameText
                            if let url = blocklist.url {
                                Text(url.absoluteString).font(.caption)
                            }
                        }
                    } icon: {
                        Image(systemName: "square.slash")
                    }
                }
                .accessibilityIdentifier("BlocklistNavLink")
            }
            
            NewBlocklistButton()
        } header: {
            Text("Blocklists", comment: "Settings section header.")
        }
    }
}
