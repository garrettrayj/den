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
    case bookmark(Bookmark)
    case feed(Feed)
    case item(Item)
    case trend(Trend)

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

    var objectID: PersistentIdentifier? {
        switch self {
        case .bookmark(let bookmark):
            return bookmark.persistentModelID
        case .feed(let feed):
            return feed.persistentModelID
        case .item(let item):
            return item.persistentModelID
        case .trend(let trend):
            return trend.persistentModelID
        }
    }

    enum CodingKeys: String, CodingKey {
        case panelID
        case objectID
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

        guard values.contains(.objectID) else {
            throw DecodeError.objectIDMissing
        }

        let objectID = try values.decode(PersistentIdentifier.self, forKey: .objectID)
        let context = ModelContext(DataController.shared.container)

        if panelID == "bookmark" {
            if let bookmark = context.model(for: objectID) as? Bookmark {
                self = .bookmark(bookmark)
                return
            }
        } else if panelID == "feed" {
            if let feed = context.model(for: objectID) as? Feed {
                self = .feed(feed)
                return
            }
        } else if panelID == "item" {
            if let item = context.model(for: objectID) as? Item {
                self = .item(item)
                return
            }
        } else if panelID == "trend" {
            if let trend = context.model(for: objectID) as? Trend {
                self = .trend(trend)
                return
            }
        }

        throw DecodeError.decodeFailed
    }
}

extension SubDetailPanel: Encodable {
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(panelID, forKey: .panelID)
        try container.encode(objectID, forKey: .objectID)
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
        guard
            let data = try? JSONEncoder().encode(self),
            let result = String(data: data, encoding: .utf8)
        else {
            return "{}"
        }
        return result
    }
}
