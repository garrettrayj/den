//
//  URL+Extensions.swift
//  Den
//
//  Created by Garrett Johnson on 8/29/23.
//  Copyright © 2023 Garrett Johnson. All rights reserved.
//

import Foundation

extension URL {
    var absoluteStringForNewFeed: String {
        self.absoluteString
            .replacingOccurrences(of: "feed:", with: "")
            .replacingOccurrences(of: "den:", with: "")
    }
}
