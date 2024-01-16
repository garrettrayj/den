//
//  FeedInspector.swift
//  Den
//
//  Created by Garrett Johnson on 5/23/20.
//  Copyright © 2020 Garrett Johnson
//

import SwiftUI

struct FeedInspector: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.useSystemBrowser) private var useSystemBrowser

    @ObservedObject var feed: Feed
    @ObservedObject var profile: Profile

    @State private var showingHideTeaserOption: Bool = false

    var body: some View {
        Form {
            Section {
                Picker(selection: $feed.itemLimitChoice) {
                    ForEach(ItemLimit.allCases, id: \.self) { choice in
                        Text(verbatim: "\(choice.rawValue)").tag(choice)
                    }
                } label: {
                    Text("Featured Items", comment: "Picker label.")
                }
                .onChange(of: feed.itemLimit) {
                    if let feedData = feed.feedData {
                        for (idx, item) in feedData.itemsArray.enumerated() {
                            item.extra = idx + 1 > feed.wrappedItemLimit
                        }
                    }

                    do {
                        try viewContext.save()
                        feed.objectWillChange.send()
                    } catch {
                        CrashUtility.handleCriticalError(error as NSError)
                    }
                }
            } header: {
                Text("Limits", comment: "Feed inspector section header.")
            }
            
            Section {
                Toggle(isOn: $feed.largePreviews) {
                    Text("Expanded Previews", comment: "Toggle label.")
                }
                .onChange(of: feed.previewStyle) {
                    do {
                        try viewContext.save()
                    } catch {
                        CrashUtility.handleCriticalError(error as NSError)
                    }
                }
                .accessibilityIdentifier("LargePreviews")

                if feed.largePreviews {
                    Toggle(isOn: $feed.showExcerpts) {
                        Text("Show Excerpts", comment: "Toggle label.")
                    }
                    .onChange(of: feed.hideTeasers) {
                        do {
                            try viewContext.save()
                        } catch {
                            CrashUtility.handleCriticalError(error as NSError)
                        }
                    }
                }

                Toggle(isOn: $feed.showBylines) {
                    Text("Show Bylines", comment: "Toggle label.")
                }
                .onChange(of: feed.hideBylines) {
                    do {
                        try viewContext.save()
                    } catch {
                        CrashUtility.handleCriticalError(error as NSError)
                    }
                }

                Toggle(isOn: $feed.showImages) {
                    Text("Show Images", comment: "Toggle label.")
                }
                .onChange(of: feed.hideImages) {
                    do {
                        try viewContext.save()
                    } catch {
                        CrashUtility.handleCriticalError(error as NSError)
                    }
                }
            } header: {
                Text("Previews", comment: "Feed inspector section header.")
            }

            Section {
                Toggle(isOn: $feed.readerMode) {
                    Text("Use Reader Automatically", comment: "Toggle label.")
                }
                .onChange(of: feed.readerMode) {
                    do {
                        try viewContext.save()
                    } catch {
                        CrashUtility.handleCriticalError(error as NSError)
                    }
                }

                Toggle(isOn: $feed.useBlocklists) {
                    Text("Use Blocklists", comment: "Toggle label.")
                }
                .onChange(of: feed.disableBlocklists) {
                    do {
                        try viewContext.save()
                    } catch {
                        CrashUtility.handleCriticalError(error as NSError)
                    }
                }
                
                Toggle(isOn: $feed.allowJavaScript) {
                    Text("Allow JavaScript", comment: "Toggle label.")
                }
                .onChange(of: feed.disableJavaScript) {
                    do {
                        try viewContext.save()
                    } catch {
                        CrashUtility.handleCriticalError(error as NSError)
                    }
                }
            } header: {
                Text("Viewing", comment: "Feed inspector section header.")
            }
        }
        .formStyle(.grouped)
        #if os(iOS)
        .background(Color(.systemGroupedBackground), ignoresSafeAreaEdges: .all)
        #endif
    }
}
