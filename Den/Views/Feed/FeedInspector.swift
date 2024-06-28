//
//  FeedInspector.swift
//  Den
//
//  Created by Garrett Johnson on 5/23/20.
//  Copyright © 2020 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

struct FeedInspector: View {
    @Environment(\.modelContext) private var modelContext

    @Bindable var feed: Feed
    
    @ScaledMetric(relativeTo: .largeTitle) var width = 300

    var body: some View {
        Form {
            Section {
                Picker(selection: $feed.wrappedItemLimit) {
                    ForEach(1...100, id: \.self) { choice in
                        Text(verbatim: "\(choice)").tag(choice)
                    }
                } label: {
                    Text("Featured Items", comment: "Picker label.")
                }
                .onChange(of: feed.itemLimit) {
                    if let feedData = feed.feedData {
                        for (idx, item) in feedData.sortedItems.enumerated() {
                            item.extra = idx + 1 > feed.wrappedItemLimit
                        }
                    }
                }
            } header: {
                Text("Limits", comment: "Feed inspector section header.")
            }
            
            Section {
                Toggle(isOn: $feed.largePreviews) {
                    Text("Expanded Previews", comment: "Toggle label.")
                }
                .accessibilityIdentifier("LargePreviews")

                if feed.largePreviews {
                    Toggle(isOn: $feed.showExcerpts) {
                        Text("Show Excerpts", comment: "Toggle label.")
                    }
                }

                Toggle(isOn: $feed.showBylines) {
                    Text("Show Bylines", comment: "Toggle label.")
                }

                Toggle(isOn: $feed.showImages) {
                    Text("Show Images", comment: "Toggle label.")
                }
            } header: {
                Text("Previews", comment: "Feed inspector section header.")
            }

            Section {
                Toggle(isOn: $feed.wrappedReaderMode) {
                    Text("Use Reader Automatically", comment: "Toggle label.")
                }

                Toggle(isOn: $feed.useBlocklists) {
                    Text("Use Blocklists", comment: "Toggle label.")
                }
                
                Toggle(isOn: $feed.allowJavaScript) {
                    Text("Allow JavaScript", comment: "Toggle label.")
                }
            } header: {
                Text("Viewing", comment: "Feed inspector section header.")
            }
        }
        .formStyle(.grouped)
        .inspectorColumnWidth(width)
        #if os(iOS)
        .background(Color(.systemGroupedBackground), ignoresSafeAreaEdges: .all)
        #endif
    }
}
