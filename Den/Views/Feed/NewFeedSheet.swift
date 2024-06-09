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

    @EnvironmentObject private var refreshManager: RefreshManager

    @Binding var webAddress: String
    @Binding var initialPageID: String?

    @State private var targetPage: Page?
    @State private var webAddressIsValid: Bool?
    @State private var webAddressValidationMessage: WebAddressValidationMessage?
    @State private var loading: Bool = false
    
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
                            urlString: $webAddress,
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
                webAddress = webAddress
                checkTargetPage()
                
                if webAddress.isEmpty {
                    textFieldFocus = true
                }
            }
            .navigationTitle(Text("New Feed", comment: "Navigation title."))
            .toolbarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    submitButton
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

    private var submitButton: some View {
        Button {
            loading = true
            guard
                let url = URL(string: webAddress.trimmingCharacters(in: .whitespacesAndNewlines)),
                let page = targetPage
            else { return }

            let newFeed = Feed.create(in: modelContext, page: page, url: url, prepend: true)

            do {
                try modelContext.save()
                Task {
                    await refreshManager.refresh(feed: newFeed)
                    dismiss()
                    webAddress = ""
                    loading = false
                }
            } catch {
                CrashUtility.handleCriticalError(error as NSError)
            }
        } label: {
            Text("Save", comment: "Button label.")
        }
        .disabled(loading || !(webAddressIsValid ?? false))
        .accessibilityIdentifier("SubmitNewFeed")
    }

    private func checkTargetPage() {
        if let pageID = initialPageID, let destinationPage = pages.first(where: {
            $0.id?.uuidString == pageID
        }) {
            targetPage = destinationPage
        } else {
            targetPage = pages.first
        }
    }
}
