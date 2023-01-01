//
//  Panels.swift
//  Den
//
//  Created by Garrett Johnson on 9/10/22.
//  Copyright © 2022 Garrett Johnson. All rights reserved.
//

import Foundation

enum RootPanel: Hashable, RawRepresentable, Decodable, Encodable{
    var rawValue: String {
        switch self {
        case .page(let uuidString):
            return "page-\(uuidString)"
        default:
            return String(describing: self)
        }
    }
    
    init?(rawValue: String) {
        if rawValue.contains("page-") {
            let uuidString = rawValue.replacingOccurrences(of: "page-", with: "")
            self = .page(uuidString)
            return
        }
        self = RootPanel.init(rawValue: rawValue)!
    }
    
    typealias RawValue = String
    
    case welcome
    case search
    case inbox
    case trends
    case page(String)
    case settings
}

enum DetailPanel: Hashable {
    case feed(Feed)
    case item(Item)
    case trend(Trend)
}

enum PagePanel: Hashable {
    case pageSettings(Page)
}

enum FeedPanel: Hashable {
    case feedSettings(Feed)
}

enum SettingsPanel: Hashable {
    case profile(Profile)
    case importFeeds
    case exportFeeds
    case security
}
