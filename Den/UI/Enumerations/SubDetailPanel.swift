//
//  SubDetailPanel.swift
//  Den
//
//  Created by Garrett Johnson on 6/19/23.
//  Copyright © 2023 Garrett Johnson
//
//  SPDX-License-Identifier: NONE
//

import Foundation

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

    var objectID: String? {
        switch self {
        case .bookmark(let bookmark):
            return bookmark.id?.uuidString
        case .feed(let feed):
            return feed.id?.uuidString
        case .item(let item):
            return item.id?.uuidString
        case .trend(let trend):
            return trend.id?.uuidString
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

        let objectID = try values.decode(String.self, forKey: .objectID)
        let predicate = NSPredicate(format: "id = %@", objectID)
        let context = PersistenceController.shared.container.viewContext

        if panelID == "bookmark" {
            let request = Bookmark.fetchRequest()
            request.predicate = predicate
            if let bookmark = try? context.fetch(request).first {
                self = .bookmark(bookmark)
                return
            }
        } else if panelID == "feed" {
            let request = Feed.fetchRequest()
            request.predicate = predicate
            if let feed = try? context.fetch(request).first {
                self = .feed(feed)
                return
            }
        } else if panelID == "item" {
            let request = Item.fetchRequest()
            request.predicate = predicate
            if let item = try? context.fetch(request).first {
                self = .item(item)
                return
            }
        } else if panelID == "trend" {
            let request = Trend.fetchRequest()
            request.predicate = predicate
            if let trend = try? context.fetch(request).first {
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
    public init?(rawValue: String) {
        guard
            let data = rawValue.data(using: .utf8),
            let result = try? JSONDecoder().decode(SubDetailPanel.self, from: data)
        else {
            return nil
        }
        self = result
    }

    public var rawValue: String {
        guard
            let data = try? JSONEncoder().encode(self),
            let result = String(data: data, encoding: .utf8)
        else {
            return "{}"
        }
        return result
    }
}
