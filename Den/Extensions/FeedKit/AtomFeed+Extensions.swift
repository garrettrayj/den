//
//  AtomFeed+Extensions.swift
//  Den
//
//  Created by Garrett Johnson on 8/18/20.
//  Copyright © 2020 Garrett Johnson. All rights reserved.
//

import Foundation

import FeedKit

extension AtomFeed: WebFeed {
    var webpage: URL? {
        guard
            let urlString = self.links?.first(where: { atomLink in
                atomLink.attributes?.rel == "alternate" || atomLink.attributes?.rel == nil
            })?.attributes?.href?.trimmingCharacters(in: .whitespacesAndNewlines),
            let webpage = URL(string: urlString)
        else {
            return nil
        }

        return webpage
    }
    
    var entriesSortedByDateAndTitle: [AtomFeedEntry]? {
        entries?.sorted(using: [
            SortDescriptor(\.published, order: .reverse),
            SortDescriptor(\.title)
        ])
    }
}
