//
//  FeedInspector.swift
//  Den
//
//  Created by Garrett Johnson on 5/23/20.
//  Copyright © 2020 Garrett Johnson. All rights reserved.
//

import SwiftUI

struct FeedInspector: View {
    @Environment(\.managedObjectContext) private var viewContext

    @ObservedObject var feed: Feed
    
    @ScaledMetric(relativeTo: .largeTitle) var width = 300

    var body: some View {
        Form {
            #if os(macOS)
            // Text comments are ommited to avoid localization files changing
            // when app is built for different platforms.
            Section {
                TextField(text: $feed.wrappedTitle) {
                    Text("Title")
                }
                .labelsHidden()
            } header: {
                Text("Title")
            }
            #endif
            
            Section {
                Picker(selection: $feed.itemLimit) {
                    ForEach(1...100, id: \.self) { choice in
                        Text(verbatim: "\(choice)").tag(Int16(choice))
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
                    } catch {
                        CrashUtility.handleCriticalError(error as NSError)
                    }
                }
            } header: {
                Text("Limits", comment: "Feed inspector section header.")
            }
            
            Section {
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
                
                Toggle(isOn: $feed.largePreviews) {
                    Text("Large Images", comment: "Toggle label.")
                }
                .onChange(of: feed.previewStyle) {
                    do {
                        try viewContext.save()
                    } catch {
                        CrashUtility.handleCriticalError(error as NSError)
                    }
                }
                .accessibilityIdentifier("LargeImages")
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
            
            #if os(macOS)
            Section {
                PagePicker(
                    selection: $feed.page,
                    labelText: Text("Move", comment: "Picker label.")
                )
                DeleteFeedButton(feed: feed).buttonStyle(.borderless)
            } header: {
                Text("Management", comment: "Feed inspector section header.")
            }
            #endif
        }
        .formStyle(.grouped)
        .inspectorColumnWidth(width)
        .scrollContentBackground(.hidden)
    }
}
