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

enum FeedURLValidationMessage {
    case cannotBeBlank
    case mustNotContainSpaces
    case mustBeginWithHTTP
    case parseError
    case unopenable
}

struct NewFeedSheet: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var refreshManager: RefreshManager

    @Binding var initialPageObjectID: NSManagedObjectID?
    @Binding var initialURLString: String

    let profile: Profile?

    @State private var urlString: String = ""
    @State private var targetPage: Page?
    @State private var urlIsValid: Bool?
    @State private var validationAttempts: Int = 0
    @State private var validationMessage: FeedURLValidationMessage?
    @State private var loading: Bool = false
    @State private var newFeed: Feed?

    var body: some View {
        VStack(spacing: 20) {
            Text("New Feed").font(.title).fontWeight(.semibold)

            if targetPage == nil || profile == nil {
                Text("No Pages Available", comment: "Add Feed error message.")
                    .font(.title2)
                    .foregroundColor(.secondary)
            } else {
                VStack(spacing: 8) {
                    Text("Web Address", comment: "URL field section label.")
                    feedUrlInput
                    VStack {
                        Group {
                            if let validationMessageText = validationMessageText {
                                validationMessageText.foregroundColor(.red)
                            } else {
                                Text(
                                    "Enter a RSS, Atom, or JSON Feed URL.",
                                    comment: "URL field guidance message."
                                )
                            }
                        }
                        .font(.caption)
                        .padding(.top, 4)
                    }
                }

                PagePicker(
                    profile: profile!,
                    selection: $targetPage,
                    labelText: Text("Page", comment: "Picker label.")
                )
                .scaledToFit()

                submitButtonSection

                Button { dismiss() } label: {
                    Label {
                        Text("Cancel", comment: "Button label.")
                    } icon: {
                        Image(systemName: "xmark.circle")
                    }
                }
                .buttonStyle(.borderless)
                .accessibilityIdentifier("add-feed-cancel-button")
            }
        }
        .frame(minWidth: 400)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(24)
        .background(GroupedBackground())
        .onAppear {
            urlString = initialURLString
            checkTargetPage()
        }
    }
    
    private var validationMessageText: Text? {
        switch validationMessage {
        case .cannotBeBlank:
            Text(
                "Web address cannot be blank.",
                comment: "URL field validation message."
            )
        case .mustNotContainSpaces:
            Text(
                "Web address must not contain spaces.",
                comment: "URL field validation message."
            )
        case .mustBeginWithHTTP:
            Text(
                "Web address must begin with “http://” or “https://”.",
                comment: "URL field validation message."
            )
        case .parseError:
            Text(
                "Web address could not be parsed.",
                comment: "URL field validation message."
            )
        case .unopenable:
            Text(
                "Web address is unopenable.",
                comment: "URL field validation message."
            )
        case .none:
            nil
        }
    }

    private var submitButtonSection: some View {
        Button {
            validateUrl()
            if urlIsValid == true {
                Task {
                    addFeed()
                    await refreshManager.refresh(feed: newFeed!)
                    newFeed?.objectWillChange.send()
                    dismiss()
                }
            }
        } label: {
            Label {
                Text("Add to \(targetPage?.nameText ?? Text("…"))", comment: "Button label.")
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
        .disabled(!(urlString.count > 0) || loading)
        .buttonStyle(.borderedProminent)
        .accessibilityIdentifier("subscribe-submit-button")
    }

    private var feedUrlInput: some View {
        // Note: Prompt text contains an invisible separator after "https" to prevent link coloring
        TextField(
            text: $urlString,
            prompt: Text("https⁣://example.com/feed.xml", comment: "Feed URL text field prompt.")
        ) {
            Text("Web Address", comment: "Feed URL text field label.")
        }
        .textFieldStyle(.roundedBorder)
        .lineLimit(1)
        .multilineTextAlignment(.center)
        .disableAutocorrection(true)
        #if os(iOS)
        .textInputAutocapitalization(.never)
        #endif
        .modifier(ShakeModifier(animatableData: CGFloat(validationAttempts)))
        .padding(.horizontal)
    }

    private func checkTargetPage() {
        if
            let pageObjectID = initialPageObjectID,
            let destinationPage = profile!.pagesArray.first(where: { page in
                page.objectID == pageObjectID
            }) {
           targetPage = destinationPage
        } else if
            let firstPage = profile?.pagesArray.first
        {
            targetPage = firstPage
        }
    }

    private func validateUrl() {
        validationMessage = nil
        urlIsValid = nil

        urlString = urlString.trimmingCharacters(in: .whitespacesAndNewlines)

        if urlString == "" {
            self.failValidation(message: .cannotBeBlank)
            return
        }

        if urlString.containsWhitespace {
            self.failValidation(message: .mustNotContainSpaces)
            return
        }

        if urlString.prefix(7).lowercased() != "http://" && urlString.prefix(8).lowercased() != "https://" {
            self.failValidation(message: .mustBeginWithHTTP)
            return
        }

        guard let url = URL(string: urlString) else {
            self.failValidation(message: .parseError)
            return
        }

        #if os(iOS)
        if !UIApplication.shared.canOpenURL(url) {
            self.failValidation(message: .unopenable)
            return
        }
        #endif

        urlIsValid = true
    }

    private func addFeed() {
        guard
            let url = URL(string: urlString),
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

    private func failValidation(message: FeedURLValidationMessage) {
        urlIsValid = false
        validationMessage = message

        #if os(iOS)
        UINotificationFeedbackGenerator().notificationOccurred(.error)
        #endif

        withAnimation(.default) { validationAttempts += 1 }
    }
}
