//
//  Panels.swift
//  Den
//
//  Created by Garrett Johnson on 9/10/22.
//  Copyright © 2022 Garrett Johnson. All rights reserved.
//

import Foundation

enum Panel: Hashable {
    case welcome
    case search
    case allItems
    case trends
    case page(Page)
    case settings
}

enum DetailPanel: Hashable {
    case feed(Feed?)
    case item(Item)
}

enum SettingsPanel: Hashable {
    case profile(Profile)
    case importFeeds
    case exportFeeds
    case security
}

enum PagePanel: Hashable {
    case pageSettings(Page)
}

enum FeedPanel: Hashable {
    case feedSettings(Feed)
}

enum TrendPanel: Hashable {
    case trend(Trend)
}
