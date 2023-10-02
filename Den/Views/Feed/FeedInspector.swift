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
            generalSection
            previewsSection

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
        .background(Color(.systemGroupedBackground).ignoresSafeArea(.all))
        #endif
    }

    private var generalSection: some View {
        Section {
            TextField(
                text: $feed.wrappedTitle,
                prompt: Text("Untitled", comment: "Text field prompt.")
            ) {
                Label {
                    Text("Title", comment: "Text field label.")
                } icon: {
                    Image(systemName: "character.cursor.ibeam")
                }
            }
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

            WebAddressTextField(
                urlString: $feed.urlString,
                isValid: $webAddressIsValid,
                validationMessage: $webAddressValidationMessage
            )
            .multilineTextAlignment(.trailing)
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
                    webAddressHasChanged = true
                }
            }
        } footer: {
            if let validationMessage = webAddressValidationMessage {
                validationMessage.text.font(.footnote)
            }
        }
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
                do {
                    try viewContext.save()
                } catch {
                    CrashUtility.handleCriticalError(error as NSError)
                }
                itemLimitHasChanged = true
            }

            Toggle(isOn: $feed.browserView) {
                Text("Open in Browser", comment: "Toggle label.")
            }
            .onChange(of: feed.browserView) {
                do {
                    try viewContext.save()
                } catch {
                    CrashUtility.handleCriticalError(error as NSError)
                }
            }

            #if os(iOS)
            if feed.browserView {
                Toggle(isOn: $feed.readerMode) {
                    Text("Enter Reader Mode", comment: "Toggle label.")
                }
                .onChange(of: feed.readerMode) {
                    do {
                        try viewContext.save()
                    } catch {
                        CrashUtility.handleCriticalError(error as NSError)
                    }
                }
            }
            #endif

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
                Toggle(isOn: $feed.hideTeasers) {
                    Text("Hide Teasers", comment: "Toggle label.")
                }
                .onChange(of: feed.hideTeasers) {
                    do {
                        try viewContext.save()
                    } catch {
                        CrashUtility.handleCriticalError(error as NSError)
                    }
                }
            }

            Toggle(isOn: $feed.hideBylines) {
                Text("Hide Bylines", comment: "Toggle label.")
            }
            .onChange(of: feed.hideBylines) {
                do {
                    try viewContext.save()
                } catch {
                    CrashUtility.handleCriticalError(error as NSError)
                }
            }

            Toggle(isOn: $feed.hideImages) {
                Text("Hide Images", comment: "Toggle label.")
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
            #if os(iOS)
            if useSystemBrowser == true {
                Text(
                    "System web browser in use. \"Enter Reader Mode\" will be ignored.",
                    comment: "Feed inspector guidance."
                ).font(.footnote)
            }
            #endif
        }
    }
}
