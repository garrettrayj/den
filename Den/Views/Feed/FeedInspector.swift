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
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.useSystemBrowser) private var useSystemBrowser

    @ObservedObject var feed: Feed
    @ObservedObject var profile: Profile

    @State private var itemLimitHasChanged: Bool = false
    @State private var showingHideTeaserOption: Bool = false
    @State private var webAddressHasChanged: Bool = false
    @State private var webAddressIsValid: Bool?
    @State private var webAddressValidationMessage: WebAddressValidationMessage?

    var body: some View {
        Form {
            Section {
                TextField(
                    text: $feed.wrappedTitle,
                    prompt: Text("Untitled", comment: "Text field prompt.")
                ) {
                    Text("Title", comment: "Text field label.")
                }
                .labelsHidden()
                .onReceive(
                    feed.publisher(for: \.title)
                        .debounce(for: 1, scheduler: DispatchQueue.main)
                        .removeDuplicates()
                ) { _ in
                    if viewContext.hasChanges {
                        do {
                            try viewContext.save()
                        } catch {
                            CrashUtility.handleCriticalError(error as NSError)
                        }
                    }
                }
            } header: {
                Text("Title", comment: "Inspector section header.")
            }

            Section {
                WebAddressTextField(
                    urlString: $feed.urlString,
                    isValid: $webAddressIsValid,
                    validationMessage: $webAddressValidationMessage
                )
                .labelsHidden()
                .onChange(of: feed.url) {
                    webAddressHasChanged = true
                }
                .onReceive(
                    feed.publisher(for: \.url)
                        .debounce(for: 1, scheduler: DispatchQueue.main)
                        .removeDuplicates()
                ) { _ in
                    if viewContext.hasChanges {
                        do {
                            try viewContext.save()
                        } catch {
                            CrashUtility.handleCriticalError(error as NSError)
                        }
                    }
                }
            } header: {
                Text("Address", comment: "Inspector section header.")
            } footer: {
                Group {
                    if let validationMessage = webAddressValidationMessage {
                        validationMessage.text
                    } else if webAddressHasChanged {
                        Text(
                            "URL change will be applied on next refresh.",
                            comment: "Feed inspector guidance."
                        )
                    }
                }
                .font(.footnote)
                .foregroundColor(.secondary)
                Spacer(minLength: 0)
            }

            previewsSection

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
                Text("Viewing", comment: "Inspector section header.")
            }

            Section {
                if let profile = feed.page?.profile {
                    PagePicker(
                        profile: profile,
                        selection: $feed.page
                    )
                    .onChange(of: feed.page) {
                        self.feed.userOrder = (feed.page?.feedsUserOrderMax ?? 0) + 1
                        do {
                            try viewContext.save()
                        } catch {
                            CrashUtility.handleCriticalError(error as NSError)
                        }
                    }
                }
            } header: {
                Text("Move", comment: "Inspector section header.")
            }

            Section {
                DeleteFeedButton(feed: feed, profile: profile)
            } header: {
                Text("Danger Zone", comment: "Inspector section header.")
            }
        }
        .formStyle(.grouped)
        #if os(iOS)
        .clipped()
        .background(Color(.systemGroupedBackground), ignoresSafeAreaEdges: .all)
        #endif
    }

    private var previewsSection: some View {
        Section {
            Picker(selection: $feed.itemLimitChoice) {
                ForEach(ItemLimit.allCases, id: \.self) { choice in
                    Text(verbatim: "\(choice.rawValue)").tag(choice)
                }
            } label: {
                Text("Item Limit", comment: "Picker label.")
            }
            .onChange(of: feed.itemLimit) {
                itemLimitHasChanged = true
                do {
                    try viewContext.save()
                } catch {
                    CrashUtility.handleCriticalError(error as NSError)
                }
            }
            Toggle(isOn: $feed.largePreviews) {
                Text("Large Previews", comment: "Toggle label.")
            }
            .onChange(of: feed.previewStyle) {
                do {
                    try viewContext.save()
                } catch {
                    CrashUtility.handleCriticalError(error as NSError)
                }
            }

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
            Text("Previews", comment: "Inspector section header.")
        } footer: {
            VStack(alignment: .leading, spacing: 8) {
                #if os(iOS)
                if useSystemBrowser == true {
                    Text(
                        "System web browser in use. \"Reader Mode\" is ignored.",
                        comment: "Feed inspector guidance."
                    ).font(.footnote)
                }
                #endif
                if itemLimitHasChanged {
                    Text(
                        "Item limit change will be applied on next refresh.",
                        comment: "Feed inspector guidance."
                    )
                }
            }
            .font(.footnote)
            .foregroundColor(.secondary)
            Spacer(minLength: 0)
        }
    }
}
