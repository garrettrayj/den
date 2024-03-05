//
//  BlocklistsTab.swift
//  Den
//
//  Created by Garrett Johnson on 11/7/23.
//  Copyright © 2023 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

struct BlocklistsTab: View {
    @State private var selection: Blocklist?
    
    @FetchRequest(sortDescriptors: [SortDescriptor(\.name, order: .forward)])
    private var blocklists: FetchedResults<Blocklist>
    
    var body: some View {
        if blocklists.isEmpty {
            ContentUnavailable {
                Label {
                    Text("No Blocklists", comment: "Content unavailable title.")
                } icon: {
                    Image(systemName: "square.slash")
                }
            } description: {
                Text(
                    "Stop ads and other annoyances in the built-in browser.",
                    comment: "No blocklists guidance."
                )
                NewBlocklistButton()
                    .buttonStyle(.borderedProminent)
                    .multilineTextAlignment(.leading)
            }
        } else {
            HStack(spacing: 0) {
                List(selection: $selection) {
                    ForEach(blocklists, id: \.self) { blocklist in
                        blocklist.nameText.tag(blocklist as Blocklist?)
                    }
                }
                .frame(width: 180)
                .safeAreaInset(edge: .bottom, alignment: .leading) {
                    NewBlocklistButton().padding()
                }
                
                if let blocklist = selection {
                    BlocklistSettings(blocklist: blocklist)
                } else {
                    HStack {
                        Spacer()
                        Text("No Selection", comment: "Content unavailable title.")
                            .font(.title)
                            .foregroundStyle(.tertiary)
                        Spacer()
                    }
                }
            }
        }
    }
}
