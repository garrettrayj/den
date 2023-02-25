//
//  AppDelegate.swift
//  Den
//
//  Created by Garrett Johnson on 5/18/20.
//  Copyright © 2020 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import UIKit

import SDWebImage
import SDWebImageSVGCoder
import SDWebImageWebPCoder

class AppDelegate: UIResponder, UIApplicationDelegate {
    override func buildMenu(with builder: UIMenuBuilder) {
        super.buildMenu(with: builder)

        builder.remove(menu: .services)
        builder.remove(menu: .format)
        builder.remove(menu: .toolbar)
    }

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        resetUserDefaultsIfNeeded()
        setupImageHandling()

        return true
    }

    private func setupImageHandling() {
        // Add additional image format support
        SDImageCodersManager.shared.addCoder(SDImageSVGCoder.shared)
        SDImageCodersManager.shared.addCoder(SDImageWebPCoder.shared)

        // Explicit list of accepted image types so servers may decide what to respond with
        let imageAcceptHeader: String  = ImageMIMEType.allCases.map({ mimeType in
            mimeType.rawValue
        }).joined(separator: ",")
        SDWebImageDownloader.shared.setValue(imageAcceptHeader, forHTTPHeaderField: "Accept")

        // After tons of tweaking this I'm still not sure what to do.
        // Setting it helps maintain lower memory usage, providing a boost to snappiness.
        // The trade-off is that it seems to cap performance overall.
        // SDImageCache.shared.config.maxMemoryCost = 1024 * 1024 * 512 // MB
    }

    private func resetUserDefaultsIfNeeded() {
        if CommandLine.arguments.contains("-in-memory") {
            let domain = Bundle.main.bundleIdentifier!
            UserDefaults.standard.removePersistentDomain(forName: domain)
        }
    }
}
