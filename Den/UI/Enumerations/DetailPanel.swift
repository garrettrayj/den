//
//  DetailPanel.swift
//  Den
//
//  Created by Garrett Johnson on 12/31/22.
//  Copyright © 2022 Garrett Johnson. All rights reserved.
//

import Foundation
import CoreData

enum DetailPanel: Hashable, Identifiable {
    enum PanelType: String {
        case bookmarks
        case feed
        case inbox
        case organizer
        case page
        case search
        case trending
        case welcome
    }
    
    case bookmarks
    case feed(URL)
    case inbox
    case organizer
    case page(URL)
    case search
    case trending
    case welcome
    
    var id: String {
        if let objectURL = objectURL {
            return "\(panelType)-\(objectURL)"
        } else {
            return panelType.rawValue
        }
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    var panelType: PanelType {
        switch self {
        case .bookmarks:
            return .bookmarks
        case .feed:
            return .feed
        case .inbox:
            return .inbox
        case .organizer:
            return .organizer
        case .page:
            return .page
        case .search:
            return .search
        case .trending:
            return .trending
        case .welcome:
            return .welcome
        }
    }

    var objectURL: URL? {
        switch self {
        case .feed(let feedObjectURL):
            return feedObjectURL
        case .page(let pageObjectURL):
            return pageObjectURL
        default:
            return nil
        }
    }

    enum CodingKeys: String, CodingKey {
        case panelType
        case objectURL
    }
}

extension DetailPanel: Decodable {
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        let panelType = try PanelType(rawValue: values.decode(String.self, forKey: .panelType))
        
        switch panelType {
        case .bookmarks:
            self = .bookmarks
        case .feed:
            let objectURL = try values.decode(URL.self, forKey: .objectURL)
            self = .feed(objectURL)
        case .inbox:
            self = .inbox
        case .organizer:
            self = .organizer
        case .page:
            let objectURL = try values.decode(URL.self, forKey: .objectURL)
            self = .page(objectURL)
        case .search:
            self = .search
        case .trending:
            self = .trending
        case .welcome:
            self = .welcome
        case .none:
            self = .welcome
        }
    }
}

extension DetailPanel: Encodable {
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(panelType.rawValue, forKey: .panelType)
        try container.encode(objectURL, forKey: .objectURL)
    }
}
