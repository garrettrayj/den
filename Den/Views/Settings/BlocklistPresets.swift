//
//  BlocklistPresets.swift
//  Den
//
//  Created by Garrett Johnson on 2/4/24.
//  Copyright © 2024 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

struct BlocklistPresets: View {
    @Environment(\.dismiss) private var dismiss
    
    @Binding var name: String
    @Binding var urlString: String
    
    @State private var blocklistOptions: [BlocklistManifest.Item] = []
    
    var body: some View {
        List {
            Section {
                ForEach(blocklistOptions) { blocklistOption in
                    Button {
                        selectOption(blocklistOption)
                    } label: {
                        VStack(alignment: .leading) {
                            Text(blocklistOption.name)
                            Text(blocklistOption.description).font(.caption)
                        }
                    }
                    .buttonStyle(.plain)
                }
            } header: {
                Text(
                    .init("[EasyList](https://easylist.to)"),
                    comment: "Blocklist presets section header."
                )
            }
        }
        .task {
            blocklistOptions = await BlocklistManifest.fetch()
        }
    }
    
    private func selectOption(_ blocklistOption: BlocklistManifest.Item) {
        name = blocklistOption.name
        urlString = blocklistOption.convertedURL.absoluteString
        dismiss()
    }
}
