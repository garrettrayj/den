//
//  FeedSettingsGeneralSection.swift
//  Den
//
//  Created by Garrett Johnson on 4/29/23.
//  Copyright © 2023 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

struct FeedSettingsGeneralSection: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.managedObjectContext) private var viewContext

    @ObservedObject var feed: Feed
    
    @State private var webAddressIsValid: Bool?
    @State private var webAddressValidationMessage: WebAddressValidationMessage?

    var body: some View {
        Section {
            TextField(text: $feed.wrappedTitle, prompt: Text("Untitled", comment: "Text field prompt.")) {
                Text("Title", comment: "Text field label.")
            }
            
            WebAddressTextField(
                isValid: $webAddressIsValid,
                validationMessage: $webAddressValidationMessage,
                webAddress: $feed.urlString,
                fieldText: feed.urlString
            )

            if let profile = feed.page?.profile {
                PagePicker(
                    profile: profile,
                    selection: $feed.page
                )
                .labelStyle(.titleOnly)
                .onChange(of: feed.page) { newPage in
                    self.feed.userOrder = (newPage?.feedsUserOrderMax ?? 0) + 1
                }
            }
        } footer: {
            if let validationMessage = webAddressValidationMessage {
                validationMessage.text
            } else if feed.changedValues().keys.contains("url") {
                Text(
                    "Web address change will be applied on next refresh.",
                    comment: "Web address changed notice."
                )
            }
        }
    }
}
