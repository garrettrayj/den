//
//  SafariUtility.swift
//  Den
//
//  Created by Garrett Johnson on 11/10/22.
//  Copyright © 2022 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SafariServices
import SwiftUI

struct SafariUtility {
    static func openLink(
        url: URL,
        controlTintColor: Color,
        readerMode: Bool? = nil
    ) {
        #if os(iOS)
        guard let rootViewController = WindowFinder.current()?.rootViewController else { return }

        let config = SFSafariViewController.Configuration()
        config.entersReaderIfAvailable = readerMode ?? false

        let safariViewController = SFSafariViewController(url: url, configuration: config)
        safariViewController.preferredControlTintColor = UIColor(controlTintColor)

        rootViewController.modalPresentationStyle = .fullScreen
        rootViewController.present(safariViewController, animated: true)
        #endif
    }
}
