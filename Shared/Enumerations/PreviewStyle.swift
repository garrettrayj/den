//
//  PreviewStyle.swift
//  Den
//
//  Created by Garrett Johnson on 2/27/23.
//  Copyright © 2023 Garrett Johnson. All rights reserved.
//

import Foundation

enum PreviewStyle: Int {
    case compressed = 0
    case expanded   = 1

    init(from stringRepresentation: String) {
        if stringRepresentation == "expanded" {
            self = .expanded
        } else {
            self = .compressed
        }
    }

    /// Value used in OPML exports
    var stringRepresentation: String {
        if self == .expanded {
            return "expanded"
        } else {
            return "compressed"
        }
    }
}
