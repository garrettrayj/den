//
//  DetailPanel.swift
//  Den
//
//  Created by Garrett Johnson on 12/31/22.
//  Copyright © 2022 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import Foundation

enum DetailPanel: Hashable, Identifiable {
    case feed(Feed)
    case inbox
    case organizer
    case page(Page)
    case search
    case tag(Tag)
    case trending
    case welcome
    
    var id: String {
        if let objectID = objectID {
            return "\(panelID)-\(objectID)"
        } else {
            return panelID
        }
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    var panelID: String {
        switch self {
        case .feed:
            return "feed"
        case .inbox:
            return "inbox"
        case .organizer:
            return "organizer"
        case .page:
            return "page"
        case .search:
            return "search"
        case .tag:
            return "tag"
        case .trending:
            return "trending"
        case .welcome:
            return "welcome"
        }
    }

    var objectID: String? {
        switch self {
        case .feed(let feed):
            return feed.id?.uuidString
        case .page(let page):
            return page.id?.uuidString
        case .tag(let tag):
            return tag.id?.uuidString
        default:
            return nil
        }
    }

    enum CodingKeys: String, CodingKey {
        case panelID
        case objectID
    }
}

extension DetailPanel: Decodable {
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        let panelID = try values.decode(String.self, forKey: .panelID)
        var detailPanel: DetailPanel = .welcome

        if panelID == "feed" && values.contains(.objectID) {
            let decodedFeedID = try values.decode(String.self, forKey: .objectID)

            let request = Feed.fetchRequest()
            request.predicate = NSPredicate(format: "id = %@", decodedFeedID)

            let context = PersistenceController.shared.container.viewContext
            if let feed = try? context.fetch(request).first {
                detailPanel = .feed(feed)
            }
        } else if panelID == "inbox" {
            detailPanel = .inbox
        } else if panelID == "organizer" {
            detailPanel = .organizer
        } else if panelID == "page" && values.contains(.objectID) {
            let decodedPageID = try values.decode(String.self, forKey: .objectID)

            let request = Page.fetchRequest()
            request.predicate = NSPredicate(format: "id = %@", decodedPageID)

            let context = PersistenceController.shared.container.viewContext
            if let page = try? context.fetch(request).first {
                detailPanel = .page(page)
            }
        } else if panelID == "tag" {
            let decodedTagID = try values.decode(String.self, forKey: .objectID)

            let request = Tag.fetchRequest()
            request.predicate = NSPredicate(format: "id = %@", decodedTagID)

            let context = PersistenceController.shared.container.viewContext
            if let tag = try? context.fetch(request).first {
                detailPanel = .tag(tag)
            }
        } else if panelID == "trending" {
            detailPanel = .trending
        }

        self = detailPanel
    }
}

extension DetailPanel: Encodable {
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(panelID, forKey: .panelID)
        try container.encode(objectID, forKey: .objectID)
    }
}

extension DetailPanel: RawRepresentable {
    public init?(rawValue: String) {
        guard
            let data = rawValue.data(using: .utf8),
            let result = try? JSONDecoder().decode(DetailPanel.self, from: data)
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
