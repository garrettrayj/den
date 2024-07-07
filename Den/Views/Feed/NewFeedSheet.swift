//
//  NewFeedSheet.swift
//  Den
//
//  Created by Garrett Johnson on 5/18/20.
//  Copyright © 2020 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftData
import SwiftUI

struct NewFeedSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    @Environment(RefreshManager.self) private var refreshManager

    @Binding var newFeed: Feed?

    @State private var targetPage: Page?
    @State private var webAddressIsValid: Bool?
    @State private var webAddressValidationMessage: WebAddressValidationMessage?
    
    @SceneStorage("NewFeedPageID") private var newFeedPageID: PersistentIdentifier?
    @SceneStorage("NewFeedURLString") private var newFeedURLString: String = ""
    
    @FocusState private var textFieldFocus: Bool
    
    @Query(sort: [
        SortDescriptor(\Page.userOrder, order: .forward),
        SortDescriptor(\Page.name, order: .forward)
    ])
    private var pages: [Page]

    var body: some View {
        NavigationStack {
            Form {
                if targetPage != nil {
                    Section {
                        WebAddressTextField(
                            urlString: $newFeedURLString,
                            isValid: $webAddressIsValid,
                            validationMessage: $webAddressValidationMessage
                        )
                        .focused($textFieldFocus)
                    } footer: {
                        Group {
                            if let validationMessage = webAddressValidationMessage {
                                validationMessage.text
                            } else {
                                Text(
                                    "Enter the web address for a RSS, Atom, or JSON feed.",
                                    comment: "Feed web address field guidance message."
                                )
                            }
                        }
                        .font(.footnote)
                    }

                    PagePicker(selection: $targetPage)
                } else {
                    Text("No Pages Available", comment: "New Feed error message.").font(.title2)
                }
            }
            .formStyle(.grouped)
            .onAppear {
                checkTargetPage()
                
                if newFeedURLString.isEmpty {
                    textFieldFocus = true
                }
            }
            .navigationTitle(Text("New Feed", comment: "Navigation title."))
            .toolbarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        createFeed()
                    } label: {
                        Text("Save", comment: "Button label.")
                    }
                    .disabled(!(webAddressIsValid ?? false))
                    .accessibilityIdentifier("SubmitNewFeed")
                }

                ToolbarItem(placement: .cancellationAction) {
                    Button(role: .cancel) {
                        dismiss()
                    } label: {
                        Text("Cancel", comment: "Button label.")
                    }
                    .accessibilityIdentifier("Cancel")
                }
            }
        }
        #if os(macOS)
        .frame(minWidth: 360, minHeight: 204)
        #endif
    }

    private func checkTargetPage() {
        if let persistentModelID = newFeedPageID, let destinationPage = pages.first(where: {
            $0.persistentModelID == persistentModelID
        }) {
            targetPage = destinationPage
        } else {
            targetPage = pages.first
        }
    }
    
    private func createFeed() {
        guard
            let url = URL(string: newFeedURLString.trimmingCharacters(in: .whitespacesAndNewlines)),
            let page = targetPage
        else { return }

        newFeed = Feed.create(in: modelContext, page: page, url: url, prepend: true)
        page.feeds?.append(newFeed!)
        
        try? modelContext.save()
        
        dismiss()
    }
}
