//
//  AtomFeedEntry+Extensions.swift
//  Den
//
//  Created by Garrett Johnson on 7/8/20.
//  Copyright © 2020 Garrett Johnson
//
//  SPDX-License-Identifier: NONE
//

import Foundation

import FeedKit

extension AtomFeedEntry: LinkableItem {
    var linkURL: URL? {
        guard
            let linkString = self.links?.first(where: { atomLink in
                atomLink.attributes?.rel == "alternate" || atomLink.attributes?.rel == nil
            })?.attributes?.href?.trimmingCharacters(in: .whitespacesAndNewlines),
            let linkURL = URL(string: linkString)
        else {
            return nil
        }

        return linkURL
    }
}
