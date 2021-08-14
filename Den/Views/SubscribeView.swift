//
//  SubscribeView.swift
//  Den
//
//  Created by Garrett Johnson on 5/18/20.
//  Copyright © 2020 Garrett Johnson. All rights reserved.
//

import SwiftUI

struct SubscribeView: View {
    @Environment(\.managedObjectContext) var viewContext
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var crashManager: CrashManager
    @EnvironmentObject var profileManager: ProfileManager
    @EnvironmentObject var refreshManager: RefreshManager
    @EnvironmentObject var subscriptionManager: SubscriptionManager

    @State private var urlText: String = ""
    @State private var urlIsValid: Bool?
    @State private var validationAttempts: Int = 0
    @State private var validationMessage: String?

    var body: some View {
        VStack(alignment: .center, spacing: 20) {
            Text("Add Subscription").font(.title)

            if subscriptionManager.destinationPage != nil {
                feedUrlInput

                if validationMessage != nil { Text(validationMessage!) }

                Spacer()

                Button(action: validateUrl) {
                    Label("Add to \(subscriptionManager.destinationPage!.wrappedName)", systemImage: "plus")
                }
                .disabled(!(urlText.count > 0))
                .buttonStyle(AccentButtonStyle())
            } else {
                missingPage
                Spacer()
            }
            Button(action: cancel) { Text("Cancel") }.buttonStyle(ActionButtonStyle())
        }
        .frame(maxHeight: .infinity, alignment: .top)
        .padding(32)
        .background(Color(UIColor.secondarySystemBackground).edgesIgnoringSafeArea(.all))
        .onAppear {
            self.urlText = self.subscriptionManager.subscribeURLString
            if self.subscriptionManager.destinationPage == nil {
                self.subscriptionManager.destinationPage = profileManager.activeProfile?.pagesArray.first
            }
        }
    }

    private var feedUrlInput: some View {
        HStack {
            TextField("https://example.com/feed.xml", text: $urlText)
                .lineLimit(1)
                .disableAutocorrection(true)

            if urlIsValid != nil {
                if urlIsValid == true {
                    Image(systemName: "checkmark.circle")
                        .foregroundColor(Color(UIColor.systemGreen))
                } else {
                    Image(systemName: "slash.circle")
                        .foregroundColor(Color(UIColor.systemRed))
                }
            }
        }
        .padding(12)
        .background(Color(UIColor.systemBackground))
        .cornerRadius(8)
        .modifier(ShakeModifier(animatableData: CGFloat(validationAttempts)))
    }

    private var missingPage: some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle")
                .resizable()
                .scaledToFit()
                .frame(width: 48, height: 48)
            Text("Create a page before adding subscriptions")
                .foregroundColor(Color(.secondaryLabel))
                .multilineTextAlignment(.center)
        }.frame(maxWidth: .infinity)
    }

    private func cancel() {
        self.presentationMode.wrappedValue.dismiss()
    }

    private func failValidation(message: String) {
        self.urlIsValid = false
        self.validationMessage = message

        withAnimation(.default) { self.validationAttempts += 1 }
    }

    private func validateUrl() {
        self.validationMessage = nil
        self.urlIsValid = nil

        if self.urlText == "" {
            self.failValidation(message: "URL cannot be blank")
            return
        }

        if self.urlText.contains(" ") {
            self.failValidation(message: "URL cannot contain spaces")
            return
        }

        if self.urlText.prefix(7).lowercased() != "http://" && self.urlText.prefix(8).lowercased() != "https://" {
            self.failValidation(message: "URL must begin with \"http://\" or \"https://\"")
            return
        }

        guard let url = URL(string: self.urlText) else {
            self.failValidation(message: "Unable to parse URL")
            return
        }

        if !UIApplication.shared.canOpenURL(url) {
            self.failValidation(message: "URL is unopenable")
            return
        }

        self.urlIsValid = true

        self.addSubscription()
    }

    private func addSubscription() {
        guard let url = URL(string: self.urlText) else { return }

        if let feed = subscriptionManager.createFeed(url: url) {
            refreshManager.refresh(feed: feed) { _ in
                self.presentationMode.wrappedValue.dismiss()
            }
        }
    }
}
