//
//  SubDetailPanel.swift
//  Den
//
//  Created by Garrett Johnson on 6/19/23.
//  Copyright © 2023 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import Foundation

enum SubDetailPanel: Hashable {
    case feed(Feed)
    case item(Item)
    case trend(Trend)
}
