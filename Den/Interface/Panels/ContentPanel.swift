//
//  ContentPanel.swift
//  Den
//
//  Created by Garrett Johnson on 12/31/22.
//  Copyright © 2022 Garrett Johnson. All rights reserved.
//

import Foundation

/// Raw representable so values may be stored in scene storage
enum ContentPanel: Hashable {
    case welcome
    case search
    case inbox
    case trends
    case page(Page)
    case settings
}
