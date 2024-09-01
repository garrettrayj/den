//
//  Collection+Extensions.swift
//  Den
//
//  Created by Garrett Johnson on 5/22/23.
//  Copyright © 2023 Garrett Johnson. All rights reserved.
//

import Foundation

extension Collection where Element: Equatable {
    func uniqueElements() -> [Element] {
        var out = [Element]()
        for element in self where !out.contains(element) {
            out.append(element)
        }

        return out
    }
}
