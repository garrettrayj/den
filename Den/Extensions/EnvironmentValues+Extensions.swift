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

private struct ProfileTintKey: EnvironmentKey {
    static let defaultValue: Color = .accentColor
}

private struct UseSystemBrowserKey: EnvironmentKey {
    static let defaultValue: Bool = true
}

extension EnvironmentValues {
    var profileTint: Color {
        get { self[ProfileTintKey.self] }
        set { self[ProfileTintKey.self] = newValue }
    }

    var useSystemBrowser: Bool {
        get { self[UseSystemBrowserKey.self] }
        set { self[UseSystemBrowserKey.self] = newValue }
    }
}
