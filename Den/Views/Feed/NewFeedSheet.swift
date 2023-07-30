//
//  NewFeedSheet.swift
//  Den
//
//  Created by Garrett Johnson on 5/18/20.
//  Copyright © 2020 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import CoreData
import SwiftUI

struct NewFeedSheet: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var refreshManager: RefreshManager

    @ObservedObject var profile: Profile

    @Binding var webAddress: String
    @Binding var initialPageID: String?
    @Binding var feedRefreshTimeout: Int

    @State private var targetPage: Page?
    @State private var webAddressIsValid: Bool?
    @State private var webAddressValidationMessage: WebAddressValidationMessage?
    @State private var loading: Bool = false
    @State private var newFeed: Feed?

    var body: some View {
        NavigationStack {
            Form {
                if targetPage != nil {
                    Section {
                        WebAddressTextField(
                            text: $webAddress,
                            isValid: $webAddressIsValid,
                            validationMessage: $webAddressValidationMessage
                        )
                        .textFieldStyle(.plain)
                        .labelsHidden()
                        .multilineTextAlignment(.center)
                        .textFieldStyle(.roundedBorder)
                        .padding(.horizontal)
                    } header: {
                        Text("Web Address", comment: "Form section label.")
                    } footer: {
                        Group {
                            if let validationMessage = webAddressValidationMessage {
                                validationMessage.text
                            } else {
                                Text(
                                    "Enter a RSS, Atom, or JSON Feed URL.",
                                    comment: "URL field guidance message."
                                )
                            }
                        }
                        .font(.caption)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity)
                    }

                    PagePicker(
                        profile: profile,
                        selection: $targetPage
                    )
                    
                    #if os(iOS)
                    Section {
                        HStack {
                            Spacer()
                            submitButton
                            Spacer()
                        }
                        .listRowBackground(Color(.clear))
                    }
                    #endif
                } else {
                    Text("No Pages Available", comment: "New Feed error message.").font(.title2)
                }
            }
            .formStyle(.grouped)
            .onAppear {
                webAddress = webAddress
                checkTargetPage()
            }
            .navigationTitle(Text("New Feed", comment: "Navigation title."))
            .toolbar {
                #if os(macOS)
                ToolbarItem(placement: .confirmationAction) {
                    submitButton
                }
                #endif
                
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
        .frame(minWidth: 360, minHeight: 240)
    }

    private var submitButton: some View {
        Button {
            Task {
                addFeed()
                await RefreshManager.refresh(feed: newFeed!, timeout: feedRefreshTimeout)
                newFeed?.page?.profile?.objectWillChange.send()
                dismiss()
            }
        } label: {
            Text(
                "Add to \(targetPage?.nameText ?? Text(verbatim: "…"))",
                comment: "Button label."
            )
        }
        .buttonStyle(.borderedProminent)
        .disabled(loading || !(webAddressIsValid ?? false))
        .accessibilityIdentifier("SubmitNewFeed")
    }

    private func checkTargetPage() {
        if
            let pageID = initialPageID,
            let destinationPage = profile.pagesArray.first(where: { page in
                page.id?.uuidString == pageID
            }) {
            targetPage = destinationPage
        } else {
            targetPage = profile.pagesArray.first
        }
    }

    private func addFeed() {
        guard
            let url = URL(string: webAddress.trimmingCharacters(in: .whitespacesAndNewlines)),
            let page = targetPage
        else { return }

        loading = true
        newFeed = Feed.create(in: viewContext, page: page, url: url, prepend: true)

        do {
            try viewContext.save()
        } catch {
            CrashUtility.handleCriticalError(error as NSError)
        }
    }
}
