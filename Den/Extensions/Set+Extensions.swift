//
//  Set+Extensions.swift
//  Den
//
//  Created by Garrett Johnson on 1/14/24.
//  Copyright © 2024 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import Foundation

/// Extend UUID Set to be RawRepresentable for compatibility with SceneStorage
extension Set: RawRepresentable where Element == UUID {
    public init?(rawValue: String) {
        guard
            let data = rawValue.data(using: .utf8),
            let result = try? JSONDecoder().decode(Set<UUID>.self, from: data) else {
            return nil
        }
        self = result
    }
    
    public var rawValue: String {
        guard
            let data = try? JSONEncoder().encode(self),
            let result = String(data: data, encoding: .utf8)
        else { return "[]" }
        return result
    }
}
