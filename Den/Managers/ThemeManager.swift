//
//  ThemeManager.swift
//  Den
//
//  Created by Garrett Johnson on 11/12/21.
//  Copyright © 2021 Garrett Johnson. All rights reserved.
//

import SwiftUI

final class ThemeManager: ObservableObject {
    var hostingWindow: UIWindow?

    var defaultStyle: Int {
        get {
            UserDefaults.standard.integer(forKey: "UIStyle")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "UIStyle")
        }
    }

    func applyUIStyle() {
        let uiStyle = UIUserInterfaceStyle.init(rawValue: defaultStyle)!
        hostingWindow?.overrideUserInterfaceStyle = uiStyle
    }
}
