//
//  QuickActionManager.swift
//  Den
//
//  Created by Garrett Johnson on 6/2/24.
//  Copyright © 2024 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

#if os(iOS)
import UIKit

@MainActor
final class QuickActionManager {
    static let shared = QuickActionManager()
    
    var shortcutItem: UIApplicationShortcutItem?
}
#endif
