//
//  BuiltInBrowser.swift
//  Den
//
//  Created by Garrett Johnson on 11/10/22.
//  Copyright © 2022 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SafariServices
import SwiftUI

struct BuiltInBrowser {
    static func openURL(
        url: URL,
        controlTintColor: Color,
        readerMode: Bool? = nil
    ) {
        #if os(iOS)
        guard
            let scene = UIApplication.shared.connectedScenes.first,
            let windowSceneDelegate = scene.delegate as? UIWindowSceneDelegate,
            let window = windowSceneDelegate.window,
            let rootViewController = window?.rootViewController
        else {
            return
        }

        let config = SFSafariViewController.Configuration()
        config.entersReaderIfAvailable = readerMode ?? false

        let safariViewController = SFSafariViewController(url: url, configuration: config)
        safariViewController.preferredControlTintColor = UIColor(controlTintColor)

        rootViewController.modalPresentationStyle = .fullScreen
        rootViewController.present(safariViewController, animated: true)
        #else
        assertionFailure("Built-in web browser is not available on macOS.")
        #endif
    }
}
