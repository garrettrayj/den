//
//  JSONFeed+Extensions.swift
//  Den
//
//  Created by Garrett Johnson on 8/18/20.
//  Copyright © 2020 Garrett Johnson. All rights reserved.
//

import Foundation

import FeedKit

extension FeedKit.JSONFeed {
    var webpage: URL? {
        if
            let urlString = self.homePageURL?.trimmingCharacters(in: .whitespacesAndNewlines),
            let linkURL = URL(string: urlString)
        {
            return linkURL
        }

        return nil
    }
}
