//
//  Set+Extensions.swift
//  Den
//
//  Created by Garrett Johnson on 1/14/24.
//  Copyright © 2024 Garrett Johnson. All rights reserved.
//

import Foundation

/// Extend UUID Set to be RawRepresentable for compatibility with SceneStorage
extension Set: @retroactive RawRepresentable where Element == UUID {
    public init?(rawValue: String) {
        guard
            let data = rawValue.data(using: .utf8),
            let result = try? JSONDecoder().decode(Set<UUID>.self, from: data) else {
            return nil
        }
        self = result
    }
    
    public var rawValue: String {
        guard let data = try? JSONEncoder().encode(self) else { return "[]" }
        
        return String(decoding: data, as: UTF8.self)
    }
}
