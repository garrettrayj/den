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
        if
            let link = self.links?.first(where: {
                $0.attributes?.rel == "alternate" || $0.attributes?.rel == nil
            }),
            let urlString = link.attributes?.href?.trimmingCharacters(in: .whitespacesAndNewlines),
            let webpage = URL(string: urlString)
        {
            return webpage
        }
        
        if
            let id = self.id?.trimmingCharacters(in: .whitespacesAndNewlines),
            let webpage = URL(string: id)
        {
            return webpage
        }
        
        return nil
    }
    
    var entriesSortedByDateAndTitle: [AtomFeedEntry]? {
        entries?.sorted(using: [
            SortDescriptor(\.published, order: .reverse),
            SortDescriptor(\.title)
        ])
    }
}
