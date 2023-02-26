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
    var unique: [Element] {
        var uniqueValues: [Element] = []
        forEach { item in
            guard !uniqueValues.contains(item) else { return }
            uniqueValues.append(item)
        }
        return uniqueValues
    }
}
