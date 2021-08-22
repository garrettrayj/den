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

    func applyUIStyle() {
        let uiStyle = UIUserInterfaceStyle.init(rawValue: UserDefaults.standard.integer(forKey: "UIStyle"))!
        window?.overrideUserInterfaceStyle = uiStyle
    }
}
