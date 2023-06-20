//
//  WebAddressTextField.swift
//  Den
//
//  Created by Garrett Johnson on 6/20/23.
//  Copyright © 2023 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

struct WebAddressTextField: View {
    @Binding var isValid: Bool?
    @Binding var validationMessage: WebAddressValidationMessage?
    @Binding var webAddress: String

    @State var fieldText: String
    
    var body: some View {
        // Note: Prompt text contains an invisible separator after "https" to prevent link coloring
        TextField(
            text: $fieldText,
            prompt: Text("https⁣://example.com/feed.xml", comment: "Web address text field prompt.")
        ) {
            Text("Address", comment: "Web address text field label.")
        }
        .lineLimit(1)
        .disableAutocorrection(true)
        #if os(iOS)
        .textInputAutocapitalization(.never)
        #endif
        .onChange(of: fieldText) { _ in
            validate()
        }
    }
    
    private func validate() {
        validationMessage = nil
        isValid = nil

        fieldText = fieldText.trimmingCharacters(in: .whitespacesAndNewlines)

        if fieldText == "" {
            self.failValidation(message: .cannotBeBlank)
            return
        }

        if fieldText.containsWhitespace {
            self.failValidation(message: .mustNotContainSpaces)
            return
        }

        if fieldText.prefix(7).lowercased() != "http://" && fieldText.prefix(8).lowercased() != "https://" {
            self.failValidation(message: .mustBeginWithHTTP)
            return
        }

        guard let url = URL(string: fieldText) else {
            self.failValidation(message: .parseError)
            return
        }

        #if os(iOS)
        if !UIApplication.shared.canOpenURL(url) {
            self.failValidation(message: .unopenable)
            return
        }
        #endif

        webAddress = fieldText
        isValid = true
    }
    
    private func failValidation(message: WebAddressValidationMessage) {
        isValid = false
        validationMessage = message
    }
}
