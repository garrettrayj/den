//
//  WebAddressTextField.swift
//  Den
//
//  Created by Garrett Johnson on 6/20/23.
//  Copyright © 2023 Garrett Johnson. All rights reserved.
//

import SwiftUI

struct WebAddressTextField: View {
    @Binding var urlString: String
    @Binding var isValid: Bool?
    @Binding var validationMessage: WebAddressValidationMessage?

    @State private var text: String = ""

    var body: some View {
        TextField(
            text: $text,
            prompt: Text(verbatim: "https⁣://example.com/feed")
            // Prompt contains an invisible separator after "https" to prevent link coloring
        ) {
            Label {
                Text("URL", comment: "Text field label.")
            } icon: {
                Image(systemName: "globe")
            }
        }
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
