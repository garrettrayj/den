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
import SwiftData

enum DetailPanel: Hashable, Identifiable {
    case bookmarks
    case feed(PersistentIdentifier)
    case inbox
    case organizer
    case page(PersistentIdentifier)
    case search
    case trending
    case welcome
    
    var id: String {
        if let persistentModelID = persistentModelID {
            return "\(panelID)-\(persistentModelID)"
        } else {
            return panelID
        }
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    var panelID: String {
        switch self {
        case .bookmarks:
            return "bookmarks"
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
        case .trending:
            return "trending"
        case .welcome:
            return "welcome"
        }
    }

    var persistentModelID: PersistentIdentifier? {
        switch self {
        case .feed(let persistentModelID):
            return persistentModelID
        case .page(let persistentModelID):
            return persistentModelID
        default:
            return nil
        }
    }

    enum CodingKeys: String, CodingKey {
        case panelID
        case persistentModelID
    }
}

extension DetailPanel: Decodable {
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        let panelID = try values.decode(String.self, forKey: .panelID)
        var detailPanel: DetailPanel = .welcome
        
        if panelID == "bookmarks" {
            detailPanel = .bookmarks
        } else if panelID == "feed" && values.contains(.persistentModelID) {
            let persistentModelID = try values.decode(
                PersistentIdentifier.self,
                forKey: .persistentModelID
            )
            detailPanel = .feed(persistentModelID)
        } else if panelID == "inbox" {
            detailPanel = .inbox
        } else if panelID == "organizer" {
            detailPanel = .organizer
        } else if panelID == "page" && values.contains(.persistentModelID) {
            let persistentModelID = try values.decode(
                PersistentIdentifier.self,
                forKey: .persistentModelID
            )
            detailPanel = .page(persistentModelID)
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
        try container.encode(persistentModelID, forKey: .persistentModelID)
    }
}
