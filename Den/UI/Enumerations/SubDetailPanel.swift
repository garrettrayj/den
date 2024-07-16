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

enum SubDetailPanel: Hashable {
    enum PanelType: String {
        case bookmark
        case feed
        case item
        case trend
    }
    
    case bookmark(URL)
    case feed(URL)
    case item(URL)
    case trend(URL)

    var panelType: PanelType {
        switch self {
        case .bookmark:
            return .bookmark
        case .feed:
            return .feed
        case .item:
            return .item
        case .trend:
            return .trend
        }
    }

    var objectURL: URL {
        switch self {
        case .bookmark(let objectURL):
            return objectURL
        case .feed(let objectURL):
            return objectURL
        case .item(let objectURL):
            return objectURL
        case .trend(let objectURL):
            return objectURL
        }
    }

    enum CodingKeys: String, CodingKey {
        case panelType
        case objectURL
    }
}

extension SubDetailPanel: Decodable {
    enum DecodeError: Error {
        case decodeFailed
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        let panelType = try PanelType(rawValue: values.decode(String.self, forKey: .panelType))
        let objectURL = try values.decode(URL.self, forKey: .objectURL)
        
        switch panelType {
        case .bookmark:
            self = .bookmark(objectURL)
        case .feed:
            self = .feed(objectURL)
        case .item:
            self = .item(objectURL)
        case .trend:
            self = .trend(objectURL)
        case .none:
            throw DecodeError.decodeFailed
        }
    }
}

extension SubDetailPanel: Encodable {
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(panelType.rawValue, forKey: .panelType)
        try container.encode(objectURL, forKey: .objectURL)
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
        guard let data = try? JSONEncoder().encode(self) else { return "{}" }
        
        return String(decoding: data, as: UTF8.self)
    }
}
