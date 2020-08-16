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
    var webpage: URL? {
        switch self {
        case .atom(let atomFeed):
            guard
                let webpageString = atomFeed.links?.first(where: { atomLink in
                    atomLink.attributes?.rel == "alternate" || atomLink.attributes?.rel == nil
                })?.attributes?.href?.trimmingCharacters(in: .whitespacesAndNewlines),
                let webpage = URL(string: webpageString)
            else {
                return nil
            }
            
            return webpage
        case .rss(let rssFeed):
            if
                let itemLinkString = rssFeed.link?.trimmingCharacters(in: .whitespacesAndNewlines),
                let linkURL = URL(string: itemLinkString)
            {
                return linkURL
            }
            
            return nil
        default:
            return nil
        }
    }
}
