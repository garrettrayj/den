//
//  ThemeManager.swift
//  Den
//
//  Created by Garrett Johnson on 11/12/21.
//  Copyright © 2021 Garrett Johnson. All rights reserved.
//

import SwiftUI

struct ThemeManager {
    static var defaultStyle: Int {
        get {
            UserDefaults.standard.integer(forKey: "UIStyle")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "UIStyle")
        }
    }

    static var userInterfaceStyle: UIUserInterfaceStyle {
        UIUserInterfaceStyle.init(rawValue: defaultStyle)!
    }

    static var colorScheme: ColorScheme? {
        ColorScheme(userInterfaceStyle)
    }

    static func applyStyle() {
        let window: UIWindow? = WindowFinder.current()
        window?.overrideUserInterfaceStyle = userInterfaceStyle
    }
}
