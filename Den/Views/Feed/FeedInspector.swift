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

    @State private var webAddressIsValid: Bool?
    @State private var webAddressValidationMessage: WebAddressValidationMessage?
    @State private var showingHideTeaserOption: Bool = false

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
        .onDisappear {
            if viewContext.hasChanges {
                do {
                    try viewContext.save()
                } catch {
                    CrashUtility.handleCriticalError(error as NSError)
                }
            }
        }
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
            .lineLimit(1)

            LabeledContent {
                WebAddressTextField(
                    text: $feed.urlString,
                    isValid: $webAddressIsValid,
                    validationMessage: $webAddressValidationMessage
                )
                .labelsHidden()
                .scaledToFit()
                .multilineTextAlignment(.trailing)
            } label: {
                Label {
                    Text("Address", comment: "Web address text field label.")
                } icon: {
                    Image(systemName: "dot.radiowaves.up.forward")
                }
            }

        } footer: {
            if let validationMessage = webAddressValidationMessage {
                validationMessage.text
            } else if feed.changedValues().keys.contains("url") {
                Text(
                    "Web address change will be applied on next refresh.",
                    comment: "Feed inspector guidance."
                ).font(.footnote)
            }
        }
    }

    private var previewsSection: some View {
        Section {
            Picker(selection: $feed.itemLimitChoice) {
                ForEach(ItemLimit.allCases, id: \.self) { choice in
                    Text("\(choice.rawValue)").tag(choice)
                }
            } label: {
                Text("Preview Limit", comment: "Picker label.")
            }

            Toggle(isOn: $feed.browserView) {
                Text("Open in Browser", comment: "Toggle label.")
            }

            #if os(iOS)
            if feed.browserView {
                Toggle(isOn: $feed.readerMode) {
                    Text("Enter Reader Mode", comment: "Toggle label.")
                }
            }
            #endif

            Toggle(isOn: $feed.largePreviews) {
                Text("Large Previews", comment: "Toggle label.")
            }

            if feed.largePreviews {
                Toggle(isOn: $feed.hideTeasers) {
                    Text("Hide Teasers", comment: "Toggle label.")
                }
            }

            Toggle(isOn: $feed.hideBylines) {
                Text("Hide Bylines", comment: "Toggle label.")
            }

            Toggle(isOn: $feed.hideImages) {
                Text("Hide Images", comment: "Toggle label.")
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

            if feed.changedValues().keys.contains("itemLimit") {
                Text(
                    "Preview limit will be applied on next refresh.",
                    comment: "Feed inspector guidance."
                ).font(.footnote)
            }
        }
    }
}
