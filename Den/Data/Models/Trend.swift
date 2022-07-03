//
//  Trend.swift
//  Den
//
//  Created by Garrett Johnson on 7/2/22.
//  Copyright © 2022 Garrett Johnson. All rights reserved.
//

import Foundation

struct Trend: Identifiable {
    var id: String
    var text: String
    var items: [Item]

    var feeds: [Feed] {
        var feeds: Set<Feed> = []
        items.forEach { item in
            if let feed = item.feedData?.feed {
                feeds.insert(feed)
            }
        }

        return Array(feeds)
    }

    var feedsWithFavicons: [Feed] {
        feeds.filter { feed in
            feed.feedData?.favicon != nil
        }
    }

    var feedsWithoutFavicons: [Feed] {
        feeds.filter { feed in
            feed.feedData?.favicon == nil
        }
    }
}

extension Trend: Equatable {
  static func == (lhs: Trend, rhs: Trend) -> Bool {
      return lhs.id == rhs.id
  }
}

extension Trend: Hashable {
  func hash(into hasher: inout Hasher) {
    hasher.combine(id)
  }
}
