//
//  String+Extensions.swift
//  Den
//
//  Created by Garrett Johnson on 8/28/20.
//  Copyright © 2020 Garrett Johnson. All rights reserved.
//

import Foundation

import SwiftSoup

/**
 Adapted from https://gist.github.com/budidino/8585eecd55fd4284afaaef762450f98e#gistcomment-2270476
 */
extension String {
    enum TruncationPosition {
        case head
        case middle
        case tail
    }

    func truncated(limit: Int, position: TruncationPosition = .tail, leader: String = "…") -> String {
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

    func strippingTags() -> String {
        guard
            let doc: Document = try? SwiftSoup.parseBodyFragment(self),
            let txt = try? doc.text()
        else {
            return self
        }

        return txt
    }

    func preparingTitle() -> String {
        self.replacingOccurrences(of: "\u{00A0}", with: " ") // NO-BREAK SPACE
            .replacingOccurrences(of: "\u{202F}", with: " ") // NARROW NO-BREAK SPACE
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .htmlUnescape()
    }

    func sanitizedForFileName() -> String {
        // For ressoning on character sets see https://superuser.com/a/358861
        let invalidCharacters = CharacterSet(charactersIn: "\\/:*?\"<>|")
            .union(.newlines)
            .union(.illegalCharacters)
            .union(.controlCharacters)

        return self
            .components(separatedBy: invalidCharacters)
            .joined(separator: "-")
    }
}
