//
//  DetailPanel.swift
//  Den
//
//  Created by Garrett Johnson on 12/31/22.
//  Copyright © 2022 Garrett Johnson
//

import Foundation

enum DetailPanel: Hashable {
    case inbox
    case organizer
    case page(Page)
    case search(String)
    case tag(Tag)
    case trending
    case welcome

    var panelID: String {
        switch self {
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

    var pageID: String? {
        if case .page(let page) = self {
            return page.id?.uuidString
        }

        return nil
    }

    var searchQuery: String? {
        if case .search(let searchQuery) = self {
            return searchQuery
        }

        return nil
    }

    var tagID: String? {
        if case .tag(let tag) = self {
            return tag.id?.uuidString
        }

        return nil
    }

    enum CodingKeys: String, CodingKey {
        case panelID
        case pageID
        case searchQuery
        case tagID
    }
}

extension DetailPanel: Decodable {
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        let panelID = try values.decode(String.self, forKey: .panelID)
        var detailPanel: DetailPanel = .welcome

        if panelID == "inbox" {
            detailPanel = .inbox
        } else if panelID == "organizer" {
            detailPanel = .organizer
        } else if panelID == "page" && values.contains(.pageID) {
            let decodedPageID = try values.decode(String.self, forKey: .pageID)

            let request = Page.fetchRequest()
            request.predicate = NSPredicate(format: "id = %@", decodedPageID)

            let context = PersistenceController.shared.container.viewContext
            if let page = try? context.fetch(request).first {
                detailPanel = .page(page)
            }
        } else if panelID == "search" && values.contains(.searchQuery) {
            let decodedSearchQuery = try values.decode(String.self, forKey: .searchQuery)
            detailPanel = .search(decodedSearchQuery)
        } else if panelID == "tag" {
            let decodedTagID = try values.decode(String.self, forKey: .tagID)

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
        try container.encode(pageID, forKey: .pageID)
        try container.encode(searchQuery, forKey: .searchQuery)
        try container.encode(tagID, forKey: .tagID)
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
