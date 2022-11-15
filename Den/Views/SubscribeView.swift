//
//  SubscribeView.swift
//  Den
//
//  Created by Garrett Johnson on 5/18/20.
//  Copyright © 2020 Garrett Johnson. All rights reserved.
//

import CoreData
import SwiftUI

struct SubscribeView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.persistentContainer) private var container

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
        Group {
            if targetPage == nil || profile == nil {
                VStack(spacing: 24) {
                    Image(systemName: "questionmark.folder").font(.system(size: 52))
                    Text("No Pages Available").font(.title2)
                    Button { dismiss() } label: {
                        Text("Cancel").font(.title3)
                    }
                    .buttonStyle(.bordered)
                    .accessibilityIdentifier("subscribe-cancel-button")
                }
                .foregroundColor(.secondary)
            } else {
                NavigationStack {
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
                                    Text("RSS, Atom, or JSON Feed")
                                }
                            }
                            .font(.caption)
                            .padding(.top, 4)
                        }.headerProminence(.increased)

                        Section {
                            pagePicker.modifier(FormRowModifier())
                        }

                        submitButtonSection
                    }
                    .onReceive(
                        NotificationCenter.default.publisher(for: .feedRefreshed, object: newFeed?.objectID)
                    ) { _ in
                        profile?.objectWillChange.send()
                        dismiss()
                    }
                    .navigationTitle("Add Feed")
                    .toolbar {
                        ToolbarItem {
                            Button { dismiss() } label: {
                                Label("Cancel", systemImage: "xmark.circle")
                            }
                            .buttonStyle(ToolbarButtonStyle())
                            .accessibilityIdentifier("subscribe-cancel-button")
                        }
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(UIColor.systemGroupedBackground).edgesIgnoringSafeArea(.all))
        .onAppear {
            urlString = initialURLString
            checkTargetPage()
        }
    }

    private var submitButtonSection: some View {
        Button {
            validateUrl()
            if urlIsValid == true {
                Task {
                    await addFeed()
                }
            }
        } label: {
            Label {
                Text("Add to \(targetPage?.wrappedName ?? "...")")
            } icon: {
                if loading {
                    ProgressView().progressViewStyle(.circular).colorInvert().padding(.trailing, 4)
                } else {
                    Image(systemName: "note.text.badge.plus")
                }
            }
        }
        .frame(maxWidth: .infinity)
        .listRowBackground(Color(UIColor.systemGroupedBackground))
        .disabled(!(urlString.count > 0) || loading)
        .buttonStyle(AccentButtonStyle())
        .accessibilityIdentifier("subscribe-submit-button")
    }

    private var feedUrlInput: some View {
        HStack {
            TextField("https://example.com/feed.xml", text: $urlString)
                .lineLimit(1)
                .multilineTextAlignment(.leading)
                .disableAutocorrection(true)
                .textInputAutocapitalization(.never)
                .modifier(ShakeModifier(animatableData: CGFloat(validationAttempts)))

            if urlIsValid != nil {
                if urlIsValid == true {
                    Image(systemName: "checkmark.circle").foregroundColor(Color(UIColor.systemGreen)).fontWeight(.medium)
                } else {
                    Image(systemName: "slash.circle").foregroundColor(Color(UIColor.systemRed)).fontWeight(.medium)
                }
            }
        }
    }

    private var pagePicker: some View {
        Picker(selection: $targetPage) {
            ForEach(profile!.pagesArray) { page in
                Text(page.wrappedName).tag(page as Page?)
            }
        } label: {
            Text("Page")
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
            self.failValidation(message: "Cannot be blank")
            return
        }

        if urlString.containsWhitespace {
            self.failValidation(message: "Must not contain spaces")
            return
        }

        if self.urlString.prefix(7).lowercased() != "http://" && self.urlString.prefix(8).lowercased() != "https://" {
            self.failValidation(message: "Must begin with “http://” or “https://”")
            return
        }

        guard let url = URL(string: self.urlString) else {
            self.failValidation(message: "Could not be parsed")
            return
        }

        if !UIApplication.shared.canOpenURL(url) {
            self.failValidation(message: "Unopenable")
            return
        }

        urlIsValid = true
    }

    private func addFeed() async {
        guard
            let container = container,
            let url = URL(string: urlString),
            let page = targetPage
        else { return }

        loading = true
        newFeed = Feed.create(in: container.viewContext, page: page, url: url, prepend: true)

        do {
            try container.viewContext.save()
        } catch {
            CrashUtility.handleCriticalError(error as NSError)
        }
        
        await RefreshUtility.refresh(container: container, feed: newFeed!)
    }

    private func failValidation(message: String) {
        urlIsValid = false
        validationMessage = message

        Haptics.notificationFeedbackGenerator.notificationOccurred(.error)
        withAnimation(.default) { validationAttempts += 1 }
    }
}
