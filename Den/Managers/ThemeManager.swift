//
//  ThemeManager.swift
//  Den
//
//  Created by Garrett Johnson on 1/4/21.
//  Copyright © 2021 Garrett Johnson. All rights reserved.
//

import SwiftUI

final class ThemeManager: ObservableObject {
    var window: UIWindow?

    var uiStyle: Binding<UIUserInterfaceStyle> {
        Binding(
            get: {
                UIUserInterfaceStyle.init(rawValue: UserDefaults.standard.integer(forKey: "UIStyle"))!
            },
            set: {
                UserDefaults.standard.setValue($0.rawValue, forKey: "UIStyle")
                self.applyUIStyle()
            }
        )
    }

    func applyUIStyle() {
        window?.overrideUserInterfaceStyle = uiStyle.wrappedValue
    }
}
