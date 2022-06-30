//
//  Array+Extensions.swift
//  Den
//
//  Created by Garrett Johnson on 6/19/22.
//  Copyright © 2022 Garrett Johnson. All rights reserved.
//

import Foundation

public extension Array where Element: Hashable {
    func uniqued() -> [Element] {
        var seen = Set<Element>()
        return filter{ seen.insert($0).inserted }
    }
}
