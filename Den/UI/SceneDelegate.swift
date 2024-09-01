//
//  SceneDelegate.swift
//  Den
//
//  Created by Garrett Johnson on 6/2/24.
//  Copyright © 2024 Garrett Johnson. All rights reserved.
//

#if os(iOS)
import UIKit

final class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    func windowScene(
        _ windowScene: UIWindowScene,
        performActionFor shortcutItem: UIApplicationShortcutItem,
        completionHandler: @escaping (Bool) -> Void
    ) {
        QuickActionManager.shared.shortcutItem = shortcutItem
        completionHandler(true)
    }
}
#endif
