//
//  FeedKitFeed+Extensions.swift
//  Den
//
//  Created by Garrett Johnson on 8/7/20.
//  Copyright © 2020 Garrett Johnson. All rights reserved.
//

import Foundation
import FeedKit


extension FeedKit.Feed {
    public var webpage: URL? {
        switch self {
        case .atom(let atomFeed):
            return atomFeed.webpage
        case .rss(let rssFeed):
            return rssFeed.webpage
        case .json(let jsonFeed):
            return jsonFeed.webpage
        }
    }
}
