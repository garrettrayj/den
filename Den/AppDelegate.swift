//
//  AppDelegate.swift
//  Den
//
//  Created by Garrett Johnson on 5/18/20.
//  Copyright © 2020 Garrett Johnson. All rights reserved.
//

import UIKit
import CoreData
import URLImage
import SwiftUI
import OSLog

/**
 AppDelegate contains handlers for application startup and OS chrome customization.
 AppDelegate has mostly been superseded by `DenApp` but is still needed for system menu customization.
 */
class AppDelegate: UIResponder, UIApplicationDelegate {
    override func buildMenu(with builder: UIMenuBuilder) {
        super.buildMenu(with: builder)

        builder.remove(menu: .services)
        builder.remove(menu: .format)
        builder.remove(menu: .toolbar)
    }
    
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil
    ) -> Bool {
        URLImageService.shared.cleanup()
        return true
    }
}
