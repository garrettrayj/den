//
//  String+Extensions.swift
//  Den
//
//  Created by Garrett Johnson on 8/28/20.
//  Copyright © 2020 Garrett Johnson. All rights reserved.
//

import Foundation


/**
 Adapted from https://gist.github.com/budidino/8585eecd55fd4284afaaef762450f98e#gistcomment-2270476
 */
extension String {
    enum TruncationPosition {
        case head
        case middle
        case tail
    }

    func truncated(limit: Int, position: TruncationPosition = .tail, leader: String = "...") -> String {
        guard self.count > limit else { return self }

        switch position {
        case .head:
            return leader + self.suffix(limit)
        case .middle:
            let headCharactersCount = Int(ceil(Float(limit - leader.count) / 2.0))

            let tailCharactersCount = Int(floor(Float(limit - leader.count) / 2.0))
            
            return "\(self.prefix(headCharactersCount))\(leader)\(self.suffix(tailCharactersCount))"
        case .tail:
            return self.prefix(limit) + leader
        }
    }
}
