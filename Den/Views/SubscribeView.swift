//
//  SubscribeView.swift
//  Den
//
//  Created by Garrett Johnson on 5/18/20.
//  Copyright © 2020 Garrett Johnson. All rights reserved.
//

import SwiftUI

struct SubscribeView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject private var profileManager: ProfileManager
    @EnvironmentObject private var refreshManager: RefreshManager
    @EnvironmentObject private var subscriptionManager: SubscriptionManager

    @State var targetPage: Page?
    @State var urlText: String = ""
    @State var urlIsValid: Bool?
    @State var validationAttempts: Int = 0
    @State var validationMessage: String?
    @State var loading: Bool = false

    @State var newFeed: Feed?

    var body: some View {
        Group {
            if targetPage == nil {
                VStack(spacing: 24) {
                    Image(systemName: "questionmark.folder").font(.system(size: 52))
                    Text("No Pages Available").font(.title2)
                    Button { dismiss() } label: {
                        Text("Cancel").font(.title3)
                    }
                    .accessibilityIdentifier("subscribe-cancel-button")
                }
                .foregroundColor(.secondary)
            } else {
                NavigationView {
                    Form {
                        Section {
                            feedUrlInput.modifier(FormRowModifier())
                        } header: {
                            Text("Web Address").frame(maxWidth: .infinity, alignment: .center)
                        } footer: {
                            Group {
                                if validationMessage != nil {
                                    Text(validationMessage!).foregroundColor(.red)
                                } else {
                                    Text("RSS, Atom, or JSON Feed")
                                }
                            }
                            .font(.callout)
                            .multilineTextAlignment(.center)
                            #if targetEnvironment(macCatalyst)
                            .padding(.top, 12)
                            #else
                            .padding(.top, 4)
                            #endif
                            .frame(maxWidth: .infinity)
                        }.headerProminence(.increased)

                        Section {
                            #if targetEnvironment(macCatalyst)
                            HStack {
                                pagePickerLabel
                                Spacer()
                                pagePicker.frame(width: 200)
                            }.modifier(FormRowModifier())
                            #else
                            pagePicker.modifier(FormRowModifier())
                            #endif
                        }

                        submitButtonSection
                    }
                    .onReceive(
                        NotificationCenter.default.publisher(for: .feedRefreshed, object: newFeed?.objectID)
                    ) { _ in
                        targetPage?.objectWillChange.send()
                        dismiss()
                    }
                    .toolbar {
                        ToolbarItem {
                            Button { dismiss() } label: {
                                Label("Cancel", systemImage: "xmark.circle")
                            }
                            .accessibilityIdentifier("subscribe-cancel-button")
                        }
                    }
                }
                .navigationViewStyle(StackNavigationViewStyle())
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(UIColor.systemGroupedBackground).edgesIgnoringSafeArea(.all))
        .onAppear {
            checkTargetPage()
        }
    }

    private var submitButtonSection: some View {
        Button {
            validateUrl()
            if urlIsValid == true {
                addFeed()
            }
        } label: {
            Label {
                Text("Add to \(targetPage!.wrappedName)")
            } icon: {
                if loading {
                    ProgressView().progressViewStyle(IconProgressStyle()).colorInvert()
                } else {
                    Image(systemName: "note.text.badge.plus")
                }
            }.padding(.leading, 4)
        }
        .frame(maxWidth: .infinity)
        .listRowBackground(Color(UIColor.systemGroupedBackground))
        .disabled(!(urlText.count > 0) || loading)
        .modifier(ProminentButtonModifier())
        .accessibilityIdentifier("subscribe-submit-button")
    }

    private var feedUrlInput: some View {
        HStack {
            TextField("https://example.com/feed.xml", text: $urlText)
                .lineLimit(1)
                .multilineTextAlignment(.center)
                .disableAutocorrection(true)
                .textInputAutocapitalization(.never)
                .modifier(ShakeModifier(animatableData: CGFloat(validationAttempts)))

            if urlIsValid != nil {
                if urlIsValid == true {
                    Image(systemName: "checkmark.circle")
                        .foregroundColor(Color(UIColor.systemGreen))
                        .imageScale(.large)
                } else {
                    Image(systemName: "slash.circle")
                        .foregroundColor(Color(UIColor.systemRed))
                        .imageScale(.large)
                }
            }
        }
    }

    private var pagePickerLabel: some View {
        Label("Page", systemImage: "target")
    }

    private var pagePicker: some View {
        Picker(selection: $targetPage) {
            ForEach(profileManager.activeProfile?.pagesArray ?? []) { page in
                Text(page.wrappedName).tag(page as Page?)
            }
            .navigationTitle("")
        } label: {
            pagePickerLabel
        }
    }

    private func checkTargetPage() {
        // Use the currently active page if available
        if let activePage = subscriptionManager.activePage {
            targetPage = activePage
        } else if
            let profile = profileManager.activeProfile,
            let firstPage = profile.pagesArray.first
        {
            targetPage = firstPage
        }
    }

    private func validateUrl() {
        validationMessage = nil
        urlIsValid = nil

        if urlText == "" {
            self.failValidation(message: "Address can not be blank")
            return
        }

        if self.urlText.contains(" ") {
            self.failValidation(message: "Address can not contain spaces")
            return
        }

        if self.urlText.prefix(7).lowercased() != "http://" && self.urlText.prefix(8).lowercased() != "https://" {
            self.failValidation(message: "Address must begin with “http://” or “https://”")
            return
        }

        guard let url = URL(string: self.urlText) else {
            self.failValidation(message: "Unable to parse address")
            return
        }

        if !UIApplication.shared.canOpenURL(url) {
            self.failValidation(message: "Unopenable address")
            return
        }

        urlIsValid = true
    }

    private func addFeed() {
        guard let url = URL(string: urlText), let page = targetPage else { return }

        self.loading = true

        newFeed = Feed.create(in: self.viewContext, page: page, url: url, prepend: true)
        refreshManager.refresh(feed: newFeed!)
    }

    private func failValidation(message: String) {
        urlIsValid = false
        validationMessage = message

        withAnimation(.default) { validationAttempts += 1 }
    }
}
