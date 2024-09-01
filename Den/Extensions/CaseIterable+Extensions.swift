//
//  CaseIterable+Extensions.swift
//  Den
//
//  Created by Garrett Johnson on 10/12/23.
//  Copyright © 2023 Garrett Johnson. All rights reserved.
//

import Foundation

extension CaseIterable where Self: Equatable, AllCases: BidirectionalCollection {
    func previous() -> Self? {
        let all = Self.allCases
        guard let idx = all.firstIndex(of: self) else { return nil }

        let previous = all.index(before: idx)
        guard all.indices.contains(previous) else { return nil }

        return all[previous]
    }

    func next() -> Self? {
        let all = Self.allCases
        guard let idx = all.firstIndex(of: self) else { return nil }

        let next = all.index(after: idx)
        guard all.indices.contains(next) else { return nil }

        return all[next]
    }
}
