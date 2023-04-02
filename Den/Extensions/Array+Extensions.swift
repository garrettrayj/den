//
//  Array+Extensions.swift
//  Den
//
//  Created by Garrett Johnson on 2/26/23.
//  Copyright © 2023 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import Foundation

extension Array where Element: Equatable {
    func uniqueElements() -> [Element] {
        var out = [Element]()
        for element in self where !out.contains(element) {
            out.append(element)
        }

        return out
    }
}
