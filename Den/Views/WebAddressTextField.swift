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
    @Binding var text: String
    @Binding var isValid: Bool?
    @Binding var validationMessage: WebAddressValidationMessage?

    var body: some View {
        // Note: Prompt text contains an invisible separator after "https" to prevent link coloring
        TextField(
            text: $text,
            prompt: Text("https⁣://example.com/feed", comment: "Web address text field prompt.")
        ) {
            Label {
                Text("Address", comment: "Web address text field label.")
            } icon: {
                Image(systemName: "dot.radiowaves.up.forward")
            }
        }
        .lineLimit(1)
        .disableAutocorrection(true)
        #if os(iOS)
        .textInputAutocapitalization(.never)
        #endif
        .onChange(of: text) { _ in
            validate()
        }
    }

    private func validate() {
        validationMessage = nil
        isValid = nil

        let trimmedInput = text.trimmingCharacters(in: .whitespacesAndNewlines)

        if trimmedInput == "" {
            self.failValidation(.cannotBeBlank)
            return
        }

        if trimmedInput.containsWhitespace {
            self.failValidation(.mustNotContainSpaces)
            return
        }

        if trimmedInput.prefix(7).lowercased() != "http://"
            && trimmedInput.prefix(8).lowercased() != "https://"
        {
            self.failValidation(.mustBeginWithHTTP)
            return
        }

        if URL(string: trimmedInput) == nil {
            self.failValidation(.parseError)
            return
        }

        isValid = true
    }

    private func failValidation(_ message: WebAddressValidationMessage) {
        isValid = false
        validationMessage = message
    }
}
