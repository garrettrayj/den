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

    @Binding var activeProfile: Profile?
    @Binding var feedRefreshTimeout: Double
    @Binding var initialPageObjectID: NSManagedObjectID?
    @Binding var initialURLString: String

    @State private var webAddress: String = ""
    @State private var targetPage: Page?
    @State private var webAddressIsValid: Bool?
    @State private var webAddressValidationMessage: WebAddressValidationMessage?
    @State private var loading: Bool = false
    @State private var newFeed: Feed?

    var body: some View {
        VStack(spacing: 24) {
            Text("Add a New Feed", comment: "Sheet title.").font(.title.weight(.semibold))

            if let profile = activeProfile, targetPage != nil {
                VStack(spacing: 8) {
                    WebAddressTextField(
                        text: $webAddress,
                        isValid: $webAddressIsValid,
                        validationMessage: $webAddressValidationMessage
                    )
                    .multilineTextAlignment(.center)
                    .textFieldStyle(.roundedBorder)
                    .padding(.horizontal)

                    if let validationMessage = webAddressValidationMessage {
                        validationMessage.text.font(.caption)
                    } else {
                        Text(
                            "Enter a RSS, Atom, or JSON Feed web address.",
                            comment: "URL field guidance message."
                        ).font(.caption)
                    }
                }

                PagePicker(
                    profile: profile,
                    selection: $targetPage
                )
                .labelStyle(.iconOnly)
                .scaledToFit()

                submitButtonSection

                Button(role: .cancel) {
                    dismiss()
                } label: {
                    Text("Cancel", comment: "Button label.")
                }
                .accessibilityIdentifier("cancel-button")
            } else {
                Text("No Pages Available", comment: "New Feed error message.").font(.title2)
            }
        }
        .frame(minWidth: 400)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(24)
        .onAppear {
            webAddress = initialURLString
            checkTargetPage()
        }
    }

    private var submitButtonSection: some View {
        Button {
            Task {
                addFeed()
                await refreshManager.refresh(feed: newFeed!, timeout: feedRefreshTimeout)
                newFeed?.objectWillChange.send()
                dismiss()
            }
        } label: {
            Label {
                Text("Add to \(targetPage?.nameText ?? Text(verbatim: "…"))", comment: "Button label.")
                    .padding(.vertical, 8)
            } icon: {
                if loading {
                    ProgressView()
                        .progressViewStyle(.circular)
                        #if os(macOS)
                        .scaleEffect(0.5)
                        .frame(width: 16)
                        #endif
                } else {
                    Image(systemName: "note.text.badge.plus")
                }
            }
            .padding(.horizontal, 8)
        }
        .frame(maxWidth: .infinity)
        .listRowBackground(Color.clear)
        .disabled(loading || !(webAddressIsValid ?? false))
        .buttonStyle(.borderedProminent)
        .accessibilityIdentifier("new-feed-submit-button")
    }

    private func checkTargetPage() {
        if
            let pageObjectID = initialPageObjectID,
            let destinationPage = activeProfile?.pagesArray.first(where: { page in
                page.objectID == pageObjectID
            }) {
           targetPage = destinationPage
        } else if
            let firstPage = activeProfile?.pagesArray.first
        {
            targetPage = firstPage
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
