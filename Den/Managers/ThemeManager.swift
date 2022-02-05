//
//  ThemeManager.swift
//  Den
//
//  Created by Garrett Johnson on 11/12/21.
//  Copyright © 2021 Garrett Johnson. All rights reserved.
//

import SwiftUI

final class ThemeManager: ObservableObject {
    // Hosting window set in app lifecycle
    var window: UIWindow?

    var defaultStyle: Int {
        get {
            UserDefaults.standard.integer(forKey: "UIStyle")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "UIStyle")
        }
    }

    var userInterfaceStyle: UIUserInterfaceStyle {
        UIUserInterfaceStyle.init(rawValue: defaultStyle)!
    }

    func applyStyle() {
        window?.overrideUserInterfaceStyle = userInterfaceStyle
    }
}
