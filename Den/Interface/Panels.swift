//
//  Panels.swift
//  Den
//
//  Created by Garrett Johnson on 12/31/22.
//  Copyright © 2022 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import Foundation

enum ContentPanel: Hashable {
    case welcome
    case search
    case inbox
    case trending
    case page(Page)
    case settings
}

enum DetailPanel: Hashable {
    case feed(Feed)
    case item(Item)
}

enum TrendingPanel: Hashable {
    case trend(Trend)
}

enum FeedPanel: Hashable {
    case feedSettings(Feed)
}

enum PagePanel: Hashable {
    case pageSettings(Page)
}

enum SettingsPanel: Hashable {
    case profileSettings(Profile)
}

enum ProfileSettingsPanel: Hashable {
    case importFeeds
    case exportFeeds
    case security
}
