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
    @State private var validationMessage: String?
    @State private var loading: Bool = false
    @State private var newFeed: Feed?

    var body: some View {
        NavigationStack {
            ZStack {
                if targetPage == nil || profile == nil {
                    VStack(spacing: 24) {
                        Text("No Pages Available").font(.title2)
                        Button { dismiss() } label: {
                            Text("Cancel").font(.title3)
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
                            Text("Web Address")
                        } footer: {
                            Group {
                                if let validationMessage = validationMessage {
                                    Text(validationMessage).foregroundColor(.red)
                                } else {
                                    Text(.init("""
                                    [RSS](https://validator.w3.org/feed/docs/rss2.html), \
                                    [Atom](https://validator.w3.org/feed/docs/atom.html), \
                                    and [JSON Feed](https://www.jsonfeed.org/version/1.1/) \
                                    supported.
                                    """))
                                }
                            }
                            .font(.caption)
                            .padding(.top, 4)
                        }
                        .modifier(ListRowModifier())

                        Section {
                            pagePicker
                        }
                        .modifier(ListRowModifier())

                        submitButtonSection
                    }
                }
            }
            .background(GroupedBackground())
            .navigationTitle(Text("Add Feed"))
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button { dismiss() } label: {
                        Label {
                            Text("Cancel")
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
                Text("Add to \(targetPage?.wrappedName ?? "…")")
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
            TextField(text: $urlString, prompt: Text("https⁣://example.com/feed.xml")) {
                Text("Web Address")
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

    private var pagePicker: some View {
        #if targetEnvironment(macCatalyst)
        HStack {
            Text("Page").modifier(FormRowModifier())
            Spacer()
            Picker(selection: $targetPage) {
                ForEach(profile!.pagesArray) { page in
                    Text(page.wrappedName).tag(page as Page?)
                }
            } label: {
                Text("Page")
            }
            .labelsHidden()
            .scaledToFit()
        }
        #else
        Picker(selection: $targetPage) {
            ForEach(profile!.pagesArray) { page in
                Text(page.wrappedName).tag(page as Page?)
            }
        } label: {
            Text("Page").modifier(FormRowModifier())
        }
        #endif
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
            self.failValidation(message: "Cannot be blank")
            return
        }

        if urlString.containsWhitespace {
            self.failValidation(message: "Must not contain spaces")
            return
        }

        if urlString.prefix(7).lowercased() != "http://" && urlString.prefix(8).lowercased() != "https://" {
            self.failValidation(message: "Must begin with “http://” or “https://”")
            return
        }

        guard let url = URL(string: urlString) else {
            self.failValidation(message: "Could not be parsed")
            return
        }

        if !UIApplication.shared.canOpenURL(url) {
            self.failValidation(message: "Unopenable")
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

    private func failValidation(message: String) {
        urlIsValid = false
        validationMessage = message

        Haptics.notificationFeedbackGenerator.notificationOccurred(.error)
        withAnimation(.default) { validationAttempts += 1 }
    }
}
