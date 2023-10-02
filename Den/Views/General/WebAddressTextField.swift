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
    @Binding var urlString: String
    @Binding var isValid: Bool?
    @Binding var validationMessage: WebAddressValidationMessage?

    @State private var text: String = ""

    var body: some View {
        // Note: Prompt text contains an invisible separator after "https" to prevent link coloring
        TextField(
            text: $text,
            prompt: Text("https⁣://example.com/feed", comment: "Web address text field prompt.")
        ) {
            Label {
                Text("URL", comment: "Web address text field label.")
            } icon: {
                Image(systemName: "dot.radiowaves.up.forward")
            }
        }
        .lineLimit(1)
        .disableAutocorrection(true)
        #if os(iOS)
        .textInputAutocapitalization(.never)
        #endif
        .onChange(of: text) {
            validate()
        }
        .onAppear {
            if urlString != "" {
                text = urlString
            }
        }
    }

    private func validate() {
        validationMessage = nil
        isValid = nil

        if text == "" {
            self.failValidation(.cannotBeBlank)
            return
        }

        if text.containsWhitespace {
            self.failValidation(.mustNotContainSpaces)
            return
        }

        if text.prefix(7).lowercased() != "http://"
            && text.prefix(8).lowercased() != "https://" {
            self.failValidation(.mustBeginWithHTTP)
            return
        }

        if URL(string: text) == nil {
            self.failValidation(.parseError)
            return
        }

        isValid = true
        validationMessage = nil

        if urlString != text {
            urlString = text
        }
    }

    private func failValidation(_ message: WebAddressValidationMessage) {
        isValid = false
        validationMessage = message
    }
}
