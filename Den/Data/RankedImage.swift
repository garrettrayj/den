//
//  RankedImage.swift
//  Den
//
//  Created by Garrett Johnson on 1/31/22.
//  Copyright © 2022 Garrett Johnson
//

import Foundation

struct RankedImage {
    var url: URL
    var rank: Int = 0
    var width: Int?
    var height: Int?
}

extension Array where Element == RankedImage {
    var topRanked: RankedImage? {
        self.sorted(by: { a, b in
            a.rank > b.rank
        }).first
    }
}
