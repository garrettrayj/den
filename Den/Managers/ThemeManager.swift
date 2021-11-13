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

    func applyUIStyle() {
        let uiStyle = UIUserInterfaceStyle.init(rawValue: UserDefaults.standard.integer(forKey: "UIStyle"))!
        hostingWindow?.overrideUserInterfaceStyle = uiStyle
    }
}
