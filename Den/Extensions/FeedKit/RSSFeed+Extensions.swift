//
//  RSSFeed+Extensions.swift
//  Den
//
//  Created by Garrett Johnson on 8/18/20.
//  Copyright © 2020 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import Foundation

import FeedKit

extension RSSFeed: WebAccessibleFeed {
    var webpage: URL? {
        if
            let urlString = self.link?.trimmingCharacters(in: .whitespacesAndNewlines),
            let link = URL(string: urlString)
        {
            return link
        }

        return nil
    }
}
