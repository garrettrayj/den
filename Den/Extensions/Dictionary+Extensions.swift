//
//  Dictionary+Extensions.swift
//  Den
//
//  Created by Garrett Johnson on 8/8/20.
//  Copyright © 2020 Garrett Johnson. All rights reserved.
//

import Foundation

extension Dictionary {
    var valuesArray: [Any] {
        var valuesArray: [Any] = []
        for (_, value) in self {
            valuesArray.append(value)
        }

        return valuesArray
    }
}
