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

enum DetailPanel: Hashable {
    case diagnostics
    case inbox
    case page(Page)
    case search(Search)
    case trending
    case welcome

    var panelID: String {
        switch self {
        case .diagnostics:
            return "diagnostics"
        case .inbox:
            return "inbox"
        case .page:
            return "page"
        case .search:
            return "search"
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

    var searchID: String? {
        if case .search(let search) = self {
            return search.id?.uuidString
        }

        return nil
    }

    enum CodingKeys: String, CodingKey {
        case panelID
        case pageID
        case searchID
    }
}

extension DetailPanel: Decodable {
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        let panelID = try values.decode(String.self, forKey: .panelID)
        var detailPanel: DetailPanel = .welcome

        if panelID == "diagnostics" {
            detailPanel = .diagnostics
        } else if panelID == "inbox" {
            detailPanel = .inbox
        } else if panelID == "page" && values.contains(.pageID) {
            let decodedPageID = try values.decode(String.self, forKey: .pageID)

            let request = Page.fetchRequest()
            request.predicate = NSPredicate(format: "id = %@", decodedPageID)

            let context = PersistenceController.shared.container.viewContext
            if let page = try? context.fetch(request).first {
                detailPanel = .page(page)
            }
        } else if panelID == "search" && values.contains(.searchID) {
            let decodedSearchID = try values.decode(String.self, forKey: .searchID)

            let request = Search.fetchRequest()
            request.predicate = NSPredicate(format: "id = %@", decodedSearchID)

            let context = PersistenceController.shared.container.viewContext
            if let search = try? context.fetch(request).first {
                detailPanel = .search(search)
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
        try container.encode(searchID, forKey: .searchID)
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
