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

private struct UseInbuiltBrowserKey: EnvironmentKey {
    static let defaultValue: Bool = true
}

extension EnvironmentValues {
    var useInbuiltBrowser: Bool {
        get { self[UseInbuiltBrowserKey.self] }
        set { self[UseInbuiltBrowserKey.self] = newValue }
    }
}
