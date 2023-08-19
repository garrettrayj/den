//
//  Environment.swift
//  Den
//
//  Created by Garrett Johnson on 10/7/22.
//  Copyright © 2022 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import CoreData
import SwiftUI

private struct FeedRefreshTimeoutKey: EnvironmentKey {
    static let defaultValue: Int = 30
}

private struct UseSystemBrowserKey: EnvironmentKey {
    static let defaultValue: Bool = true
}

extension EnvironmentValues {
    var feedRefreshTimeout: Int {
        get { self[FeedRefreshTimeoutKey.self] }
        set { self[FeedRefreshTimeoutKey.self] = newValue }
    }

    var useSystemBrowser: Bool {
        get { self[UseSystemBrowserKey.self] }
        set { self[UseSystemBrowserKey.self] = newValue }
    }
}
