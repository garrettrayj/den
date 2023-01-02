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

struct SafariUtility {
    static func openLink(
        url: URL?,
        readerMode: Bool = false
    ) {
        guard
            let url = url,
            let rootViewController = WindowFinder.current()?.rootViewController
        else { return }

        let config = SFSafariViewController.Configuration()
        config.entersReaderIfAvailable = readerMode

        let safariViewController = SFSafariViewController(url: url, configuration: config)

        rootViewController.modalPresentationStyle = .fullScreen
        rootViewController.present(safariViewController, animated: true)
    }
}
