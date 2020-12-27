//
//  StyleChanger.swift
//  Den
//
//  Created by Garrett Johnson on 12/26/20.
//  Copyright © 2020 Garrett Johnson. All rights reserved.
//

import Foundation
import SwiftUI

class UserInterfaceStyle {
    static var shared = UserInterfaceStyle()
    
    var window: UIWindow?
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
        window?.overrideUserInterfaceStyle = uiStyle.wrappedValue
    }
}
