//
//  BlocklistPresets.swift
//  Den
//
//  Created by Garrett Johnson on 2/4/24.
//  Copyright © 2024 Garrett Johnson. All rights reserved.
//

import SwiftUI

struct BlocklistPresets: View {
    @Environment(\.dismiss) private var dismiss
    
    @Binding var name: String
    @Binding var urlString: String
    
    @State private var manifestCollections: [BlocklistManifest.ManifestCollection] = []
    
    var body: some View {
        List {
            ForEach(manifestCollections) { manifestCollection in
                Section {
                    ForEach(manifestCollection.filterLists) { manifestItem in
                        Button {
                            selectOption(manifestItem)
                        } label: {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(manifestItem.name)
                                Text(manifestItem.description).font(.caption)
                            }
                        }
                        .buttonStyle(.plain)
                        .accessibilityIdentifier("BlocklistPresetOption")
                        .padding(.vertical, 4)
                    }
                } header: {
                    Link(destination: manifestCollection.website) {
                        Label {
                            Text(manifestCollection.name)
                        } icon: {
                            Image(systemName: "link")
                        }
                    }
                }
            }
        }
        .task {
            manifestCollections = await BlocklistManifest.fetch()
        }
        #if os(macOS)
        .frame(minWidth: 360, idealWidth: 460, minHeight: 420)
        #endif
    }
    
    private func selectOption(_ blocklistOption: BlocklistManifest.ManifestItem) {
        name = blocklistOption.name
        urlString = blocklistOption.convertedURL.absoluteString
        dismiss()
    }
}
