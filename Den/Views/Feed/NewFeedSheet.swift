//
//  NewFeedSheet.swift
//  Den
//
//  Created by Garrett Johnson on 5/18/20.
//  Copyright © 2020 Garrett Johnson
//

import CoreData
import SwiftUI

struct NewFeedSheet: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss

    @ObservedObject var profile: Profile

    @Binding var webAddress: String
    @Binding var initialPageID: String?

    @State private var targetPage: Page?
    @State private var webAddressIsValid: Bool?
    @State private var webAddressValidationMessage: WebAddressValidationMessage?
    @State private var loading: Bool = false

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
                        .labelsHidden()
                    } header: {
                        Text("Web Address", comment: "Form field header.")
                    } footer: {
                        Group {
                            if let validationMessage = webAddressValidationMessage {
                                validationMessage.text
                            } else {
                                Text(
                                    "Enter the URL for a RSS, Atom, or JSON feed.",
                                    comment: "Feed web address field guidance message."
                                )
                            }
                        }
                        .font(.footnote)
                    }

                    PagePicker(
                        profile: profile,
                        selection: $targetPage
                    )
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
        .frame(minWidth: 360, minHeight: 240)
    }

    private var submitButton: some View {
        Button {
            loading = true
            guard
                let url = URL(string: webAddress.trimmingCharacters(in: .whitespacesAndNewlines)),
                let page = targetPage
            else { return }

            let newFeed = Feed.create(in: viewContext, page: page, url: url, prepend: true)

            do {
                try viewContext.save()
                Task {
                    await RefreshManager.refresh(feed: newFeed)
                    newFeed.page?.profile?.objectWillChange.send()
                    dismiss()
                    webAddress = ""
                    loading = false
                }
            } catch {
                CrashUtility.handleCriticalError(error as NSError)
            }
        } label: {
            Text("Add Feed", comment: "Button label.")
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

    private func addFeed() -> Feed? {
        guard
            let url = URL(string: webAddress.trimmingCharacters(in: .whitespacesAndNewlines)),
            let page = targetPage
        else { return nil }

        let newFeed = Feed.create(in: viewContext, page: page, url: url, prepend: true)

        return newFeed
    }
}
