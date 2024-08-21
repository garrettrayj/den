//
//  ViewerOption.swift
//  Den
//
//  Created by Garrett Johnson on 8/18/24.
//  Copyright © 2024 
//
//  SPDX-License-Identifier: MIT
//

import Foundation

enum ViewerOption: String {
    case builtInViewer
    case systemBrowser
    #if os(iOS)
    case inAppSafari
    #endif
}
