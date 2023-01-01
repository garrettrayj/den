//
//  FeedPanel.swift
//  Den
//
//  Created by Garrett Johnson on 12/31/22.
//  Copyright © 2022 Garrett Johnson. All rights reserved.
//

import Foundation

enum FeedPanel: Hashable, RawRepresentable, Decodable, Encodable {
    typealias RawValue = String
    
    case feedSettings(String)
    
    init?(rawValue: String) {
        if rawValue.contains("feedSettings-") {
            let uuidString = rawValue.replacingOccurrences(of: "feedSettings-", with: "")
            self = .feedSettings(uuidString)
            return
        }

        self = FeedPanel.init(rawValue: rawValue)!
    }
    
    var rawValue: String {
        switch self {
        case .feedSettings(let uuidString):
            return "feedSettings-\(uuidString)"
        }
    }
}

