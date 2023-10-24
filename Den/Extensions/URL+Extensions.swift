//
//  URL+Extensions.swift
//  Den
//
//  Created by Garrett Johnson on 8/29/23.
//  Copyright © 2023 Garrett Johnson
//

import Foundation

extension URL {
    var absoluteStringForNewFeed: String {
        self.absoluteString
            .replacingOccurrences(of: "feed:", with: "")
            .replacingOccurrences(of: "den:", with: "")
    }

    var removingQueries: URL {
        if var components = URLComponents(string: absoluteString) {
            components.query = nil
            return components.url ?? self
        } else {
            return self
        }
    }
}
