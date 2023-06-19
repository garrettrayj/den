//
//  DetailPanel.swift
//  Den
//
//  Created by Garrett Johnson on 12/31/22.
//  Copyright © 2022 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import Foundation

enum DetailPanel: Hashable {
    case welcome
    case search
    case inbox
    case trending
    case page(Page)
}
