//
//  DenUserDefaults.swift
//  Den
//
//  Created by Garrett Johnson on 6/26/20.
//  Copyright © 2020 Garrett Johnson. All rights reserved.
//

import Foundation
import SwiftUI

/**
 SwiftUI bindings for user settings
 */
class DenUserDefaults {
    static let shared = DenUserDefaults()

    var uiStyle: Binding<UIUserInterfaceStyle> {
        Binding (
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
        SceneDelegate.shared?.window!.overrideUserInterfaceStyle = uiStyle.wrappedValue
    }
}
