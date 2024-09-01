//
//  JSONFeedItem+Extensions.swift
//  Den
//
//  Created by Garrett Johnson on 8/18/20.
//  Copyright © 2020 Garrett Johnson. All rights reserved.
//

import Foundation

import FeedKit

extension JSONFeedItem: WebFeedItem {
    /**
     Returns a webpage URL for the item; <link> value is preferred, with fallback to <guid>.
     For example, items from https://devblogs.microsoft.com/feed/landingpage/ do not include a link.
     */
    var linkURL: URL? {
        if
            let itemLinkString = self.url?.trimmingCharacters(in: .whitespacesAndNewlines),
            let linkURL = URL(string: itemLinkString)
        {
            return linkURL
        } else if
            let itemGUIDString = self.id?.trimmingCharacters(in: .whitespacesAndNewlines),
            let linkURL = URL(string: itemGUIDString)
        {
            return linkURL
        }

        return nil
    }
}
