//
//  UserDefaultManager.swift
//  Den
//
//  Created by Garrett Johnson on 8/19/20.
//  Copyright © 2020 Garrett Johnson. All rights reserved.
//

import Foundation
import SwiftUI

/**
 SwiftUI bindings for user settings
 */
class UserDefaultsManager: ObservableObject {
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
