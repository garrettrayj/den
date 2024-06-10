//
//  OrganizerInspectorConfig.swift
//  Den
//
//  Created by Garrett Johnson on 9/11/23.
//  Copyright © 2023 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

struct OrganizerOptionsPanel: View {
    @Environment(\.modelContext) private var modelContext

    @Binding var selection: Set<Feed>
    
    let pages: [Page]

    var body: some View {
        if sources.isEmpty {
            Text("No Selection", comment: "Inspector selection message.").font(.title)
        } else {
            Form {
                Section {
                    Picker(sources: sources, selection: \.wrappedItemLimit) {
                        ForEach(1...100, id: \.self) { choice in
                            Text(verbatim: "\(choice)").tag(choice)
                        }
                    } label: {
                        Text("Featured Items", comment: "Picker label.")
                    }
                } header: {
                    Text("Limits", comment: "Organizer configuration panel section header.")
                }
                
                Section {
                    Toggle(sources: sources, isOn: \.largePreviews) {
                        Text("Expanded Previews", comment: "Toggle label.")
                    }
                    Toggle(sources: sources, isOn: \.showExcerpts) {
                        Text("Show Excerpts", comment: "Toggle label.")
                    }
                    Toggle(sources: sources, isOn: \.showBylines) {
                        Text("Show Bylines", comment: "Toggle label.")
                    }
                    Toggle(sources: sources, isOn: \.showImages) {
                        Text("Show Images", comment: "Toggle label.")
                    }
                } header: {
                    Text("Previews", comment: "Organizer configuration panel section header.")
                }

                Section {
                    Toggle(sources: sources, isOn: \.wrappedReaderMode) {
                        Text("Use Reader Automatically", comment: "Toggle label.")
                    }
                    
                    Toggle(sources: sources, isOn: \.useBlocklists) {
                        Text("Use Blocklists", comment: "Toggle label.")
                    }
                    
                    Toggle(sources: sources, isOn: \.allowJavaScript) {
                        Text("Allow JavaScript", comment: "Toggle label.")
                    }
                } header: {
                    Text("Viewing", comment: "Organizer configuration panel section header.")
                }

                Section {
                    Picker(sources: sources, selection: \.page) {
                        ForEach(pages) { page in
                            page.displayName.tag(page as Page?)
                        }
                    } label: {
                        Label {
                            Text("Move", comment: "Picker label.")
                        } icon: {
                            Image(systemName: "folder")
                        }
                    }
                    .lineLimit(1)
                    #if os(iOS)
                    .pickerStyle(.navigationLink)
                    #endif
                    
                    Button(role: .destructive) {
                        selection.forEach { feed in
                            if let feedData = feed.feedData { modelContext.delete(feedData) }
                            modelContext.delete(feed)
                            selection.remove(feed)
                        }
                    } label: {
                        DeleteLabel()
                    }
                    .buttonStyle(.borderless)
                } header: {
                    Text("Management", comment: "Organizer configuration panel section header.")
                }
            }
        }
    }

    private var sources: Binding<[Feed]> {
        Binding(
            get: { selection.filter { _ in true } },
            set: {
                for feed in $0 where feed.hasChanges {
                    if let feedData = feed.feedData {
                        for (idx, item) in feedData.itemsArray.enumerated() {
                            item.extra = idx + 1 > feed.wrappedItemLimit
                        }
                    }
                }
            }
        )
    }
}
