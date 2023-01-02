//
//  WindowFinder.swift
//  Den
//
//  Created by Garrett Johnson on 8/27/22.
//  Copyright © 2022 Garrett Johnson
//

import SwiftUI

struct WindowFinder {
    static func current() -> UIWindow? {
        guard let scene = UIApplication.shared.connectedScenes.first,
              let windowSceneDelegate = scene.delegate as? UIWindowSceneDelegate,
              let window = windowSceneDelegate.window else {
            return nil
        }

        return window
    }
}
