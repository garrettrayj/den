//
//  WebAddressValidationMessage.swift
//  Den
//
//  Created by Garrett Johnson on 6/20/23.
//  Copyright © 2023 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

enum WebAddressValidationMessage {
    case cannotBeBlank
    case mustNotContainSpaces
    case mustBeginWithHTTP
    case parseError

    var text: Text {
        switch self {
        case .cannotBeBlank:
            Text(
                "Address cannot be blank.",
                comment: "URL field validation message."
            )
        case .mustNotContainSpaces:
            Text(
                "Address must not contain spaces.",
                comment: "URL field validation message."
            )
        case .mustBeginWithHTTP:
            Text(
                "Address must begin with “http://” or “https://”.",
                comment: "URL field validation message."
            )
        case .parseError:
            Text(
                "Address could not be parsed.",
                comment: "URL field validation message."
            )
        }
    }
}
