//
//  BlocklistSource.swift
//  Den
//
//  Created by Garrett Johnson on 1/26/24.
//  Copyright © 2024 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import Foundation

struct BlocklistSource: Encodable {
    var id: String
    var name: String
    var description: String
    var convertedURL: URL
    var sourceURL: URL
    var supportURL: URL
    var convertedCount: Int = 0
    var errorsCount: Int = 0
}
