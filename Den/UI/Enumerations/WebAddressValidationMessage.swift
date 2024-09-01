//
//  WebAddressValidationMessage.swift
//  Den
//
//  Created by Garrett Johnson on 6/20/23.
//  Copyright © 2023 Garrett Johnson. All rights reserved.
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
            return Text(
                "Address cannot be blank.",
                comment: "URL field validation message."
            )
        case .mustNotContainSpaces:
            return Text(
                "Address must not contain spaces.",
                comment: "URL field validation message."
            )
        case .mustBeginWithHTTP:
            return Text(
                "Address must begin with “http://” or “https://”.",
                comment: "URL field validation message."
            )
        case .parseError:
            return Text(
                "Address could not be parsed.",
                comment: "URL field validation message."
            )
        }
    }
}
