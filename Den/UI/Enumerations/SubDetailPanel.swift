//
//  SubDetailPanel.swift
//  Den
//
//  Created by Garrett Johnson on 6/19/23.
//  Copyright © 2023 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import Foundation
import SwiftData

enum SubDetailPanel: Hashable {
    case bookmark(PersistentIdentifier)
    case feed(PersistentIdentifier)
    case item(PersistentIdentifier)
    case trend(PersistentIdentifier)

    var panelID: String {
        switch self {
        case .bookmark:
            return "bookmark"
        case .feed:
            return "feed"
        case .item:
            return "item"
        case .trend:
            return "trend"
        }
    }

    var persistentModelID: PersistentIdentifier? {
        switch self {
        case .bookmark(let persistentModelID):
            return persistentModelID
        case .feed(let persistentModelID):
            return persistentModelID
        case .item(let persistentModelID):
            return persistentModelID
        case .trend(let persistentModelID):
            return persistentModelID
        }
    }

    enum CodingKeys: String, CodingKey {
        case panelID
        case persistentModelID
    }
}

extension SubDetailPanel: Decodable {
    enum DecodeError: Error {
        case objectIDMissing
        case decodeFailed
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        let panelID = try values.decode(String.self, forKey: .panelID)

        guard values.contains(.persistentModelID) else {
            throw DecodeError.objectIDMissing
        }

        let persistentModelID = try values.decode(
            PersistentIdentifier.self,
            forKey: .persistentModelID
        )

        if panelID == "bookmark" {
            self = .bookmark(persistentModelID)
            return
        } else if panelID == "feed" {
            self = .feed(persistentModelID)
            return
        } else if panelID == "item" {
            self = .item(persistentModelID)
            return
        } else if panelID == "trend" {
            self = .trend(persistentModelID)
            return
        }

        throw DecodeError.decodeFailed
    }
}

extension SubDetailPanel: Encodable {
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(panelID, forKey: .panelID)
        try container.encode(persistentModelID, forKey: .persistentModelID)
    }
}

extension SubDetailPanel: RawRepresentable {
    init?(rawValue: String) {
        guard
            let data = rawValue.data(using: .utf8),
            let result = try? JSONDecoder().decode(SubDetailPanel.self, from: data)
        else {
            return nil
        }
        self = result
    }

    var rawValue: String {
        guard let data = try? JSONEncoder().encode(self) else {
            return "{}"
        }

        return String(decoding: data, as: UTF8.self)
    }
}
