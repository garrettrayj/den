//
//  BlocklistsSection.swift
//  Den
//
//  Created by Garrett Johnson on 10/13/23.
//  Copyright © 2023 Garrett Johnson. All rights reserved.
//

import SwiftUI

struct BlocklistsSection: View {
    @State private var showingSheet = false
    
    @FetchRequest(sortDescriptors: [SortDescriptor(\.name, order: .forward)])
    private var blocklists: FetchedResults<Blocklist>

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
            
            Button {
                showingSheet = true
            } label: {
                Label {
                    Text("New Blocklist", comment: "Button label.")
                } icon: {
                    Image(systemName: "plus")
                }
            }
            .accessibilityIdentifier("NewBlocklist")
            .sheet(isPresented: $showingSheet) {
                NewBlocklistSheet()
            }
        } header: {
            Text("Blocklists", comment: "Settings section header.")
        }
    }
}
