//
//  DetailPanel.swift
//  Den
//
//  Created by Garrett Johnson on 12/31/22.
//  Copyright © 2022 Garrett Johnson. All rights reserved.
//

import Foundation

enum DetailPanel: Hashable, RawRepresentable, Decodable, Encodable {
    typealias RawValue = String
    
    case feed(String)
    case item(String)
    case trend(String)
    
    init?(rawValue: String) {
        if rawValue.contains("feed-") {
            let uuidString = rawValue.replacingOccurrences(of: "feed-", with: "")
            self = .feed(uuidString)
            return
        }
        
        if rawValue.contains("item-") {
            let uuidString = rawValue.replacingOccurrences(of: "item-", with: "")
            self = .item(uuidString)
            return
        }
        
        if rawValue.contains("trend-") {
            let uuidString = rawValue.replacingOccurrences(of: "trend-", with: "")
            self = .trend(uuidString)
            return
        }
        
        self = DetailPanel.init(rawValue: rawValue)!
    }
    
    var rawValue: String {
        switch self {
        case .feed(let uuidString):
            return "feed-\(uuidString)"
        case .item(let uuidString):
            return "item-\(uuidString)"
        case .trend(let uuidString):
            return "trend-\(uuidString)"
        }
    }
}
