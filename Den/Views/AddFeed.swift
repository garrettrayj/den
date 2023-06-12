//
//  AddFeed.swift
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

struct AddFeed: View {
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
        NavigationStack {
            ZStack {
                if targetPage == nil || profile == nil {
                    VStack(spacing: 24) {
                        Text("No Pages Available", comment: "Add Feed error message.").font(.title2)
                        Button { dismiss() } label: {
                            Text("Cancel", comment: "Button label.").font(.title3)
                        }
                        .buttonStyle(.bordered)
                        .accessibilityIdentifier("subscribe-cancel-button")
                    }
                    .foregroundColor(.secondary)
                } else {
                    Form {
                        Section {
                            feedUrlInput.modifier(FormRowModifier())
                        } header: {
                            Text("Web Address", comment: "URL field section label.")
                        } footer: {
                            Group {
                                if let validationMessage = validationMessage {
                                    Group {
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
                                        }
                                    }.foregroundColor(.red)
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
                        .modifier(ListRowModifier())

                        Section {
                            PagePicker(profile: profile!, selection: $targetPage)
                        }
                        .modifier(ListRowModifier())

                        submitButtonSection
                    }
                }
            }
            .background(GroupedBackground())
            .navigationTitle(Text("Add Feed", comment: "Navigation title."))
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button { dismiss() } label: {
                        Label {
                            Text("Cancel", comment: "Button label.")
                        } icon: {
                            Image(systemName: "xmark.circle")
                        }
                    }
                    .buttonStyle(PlainToolbarButtonStyle())
                    .accessibilityIdentifier("add-feed-cancel-button")
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onAppear {
            urlString = initialURLString
            checkTargetPage()
        }
    }

    private var submitButtonSection: some View {
        Button {
            validateUrl()
            if urlIsValid == true {
                addFeed()
                Task {
                    await refreshManager.refresh(feed: newFeed!)
                    newFeed?.objectWillChange.send()
                    dismiss()
                }
            }
        } label: {
            Label {
                Text("Add to \(targetPage?.wrappedName ?? "…")", comment: "Button label.")
            } icon: {
                if loading {
                    ProgressView()
                        .progressViewStyle(.circular)
                        .tint(Color.white)
                        .padding(.trailing, 4)
                } else {
                    Image(systemName: "note.text.badge.plus")
                }
            }
        }
        .frame(maxWidth: .infinity)
        .listRowBackground(Color.clear)
        .disabled(!(urlString.count > 0) || loading)
        .buttonStyle(AccentButtonStyle())
        .accessibilityIdentifier("subscribe-submit-button")
    }

    private var feedUrlInput: some View {
        HStack {
            // Note: Prompt text contains an invisible separator after "https" to prevent link coloring
            TextField(
                text: $urlString,
                prompt: Text("https⁣://example.com/feed.xml", comment: "Feed URL text field prompt.")
            ) {
                Text("Web Address", comment: "Feed URL text field label.")
            }
            .lineLimit(1)
            .multilineTextAlignment(.leading)
            .disableAutocorrection(true)
            .textInputAutocapitalization(.never)
            .modifier(ShakeModifier(animatableData: CGFloat(validationAttempts)))

            if urlIsValid != nil {
                if urlIsValid == true {
                    Image(systemName: "checkmark.circle")
                        .foregroundColor(.green)
                        .fontWeight(.medium)
                } else {
                    Image(systemName: "slash.circle")
                        .foregroundColor(.red)
                        .fontWeight(.medium)
                }
            }
        }
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

        if !UIApplication.shared.canOpenURL(url) {
            self.failValidation(message: .unopenable)
            return
        }

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

        UINotificationFeedbackGenerator().notificationOccurred(.error)
        withAnimation(.default) { validationAttempts += 1 }
    }
}
