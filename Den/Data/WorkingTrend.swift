//
//  WorkingTrend.swift
//  Den
//
//  Created by Garrett Johnson on 7/2/22.
//  Copyright © 2022 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import Foundation
import NaturalLanguage

struct WorkingTrend: Identifiable {
    var id: String {
        "\(slug)-\(tag.rawValue)"
    }
    var slug: String
    var tag: NLTag
    var title: String
    var items: [Item]

    var feeds: [Feed] {
        var feeds: Set<Feed> = []
        items.forEach { item in
            if let feed = item.feedData?.feed {
                feeds.insert(feed)
            }
        }

        return feeds.sorted { lhs, rhs in
            lhs.wrappedTitle < rhs.wrappedTitle
        }
    }
}

extension WorkingTrend: Equatable {
  static func == (lhs: WorkingTrend, rhs: WorkingTrend) -> Bool {
      return lhs.id == rhs.id
  }
}

extension WorkingTrend: Hashable {
  func hash(into hasher: inout Hasher) {
    hasher.combine(id)
  }
}
