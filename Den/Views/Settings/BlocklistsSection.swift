//
//  BlocklistsSection.swift
//  Den
//
//  Created by Garrett Johnson on 10/13/23.
//  Copyright © 2023 Garrett Johnson
//

import SwiftUI

struct BlocklistsSection: View {
    @FetchRequest(sortDescriptors: [SortDescriptor(\.name, order: .forward)])
    private var blocklists: FetchedResults<Blocklist>

    var body: some View {
        Section {
            if blocklists.isEmpty {
                Text("No Blocklists")
            } else {
                ForEach(blocklists) { blocklist in
                    NavigationLink {
                        BlocklistSettings(blocklist: blocklist).navigationTitle(blocklist.nameText)
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
            }
            
            NewBlocklistButton()
        } header: {
            Text("Blocklists", comment: "Section header.")
        }
    }
}
