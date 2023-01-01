//
//  PagePanel.swift
//  Den
//
//  Created by Garrett Johnson on 12/31/22.
//  Copyright © 2022 Garrett Johnson. All rights reserved.
//

import Foundation

enum PagePanel: Hashable, RawRepresentable, Decodable, Encodable {
    typealias RawValue = String
    
    case pageSettings(String)
    
    init?(rawValue: String) {
        if rawValue.contains("pageSettings-") {
            let uuidString = rawValue.replacingOccurrences(of: "pageSettings-", with: "")
            self = .pageSettings(uuidString)
            return
        }

        self = PagePanel.init(rawValue: rawValue)!
    }
    
    var rawValue: String {
        switch self {
        case .pageSettings(let uuidString):
            return "pageSettings-\(uuidString)"
        }
    }
}
