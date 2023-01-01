//
//  SettingsPanel.swift
//  Den
//
//  Created by Garrett Johnson on 12/31/22.
//  Copyright © 2022 Garrett Johnson. All rights reserved.
//

import Foundation

enum SettingsPanel: Hashable, RawRepresentable, Decodable, Encodable {
    typealias RawValue = String
    
    case profile(String)
    case importFeeds
    case exportFeeds
    case security
    
    init?(rawValue: String) {
        if rawValue.contains("profile-") {
            let uuidString = rawValue.replacingOccurrences(of: "profile-", with: "")
            self = .profile(uuidString)
            return
        }

        self = SettingsPanel.init(rawValue: rawValue)!
    }
    
    var rawValue: String {
        switch self {
        case .profile(let uuidString):
            return "profile-\(uuidString)"
        default:
            return String(describing: self)
        }
    }
}
