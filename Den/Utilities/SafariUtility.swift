//
//  SafariUtility.swift
//  Den
//
//  Created by Garrett Johnson on 11/10/22.
//  Copyright © 2022 Garrett Johnson. All rights reserved.
//

import SafariServices

struct SafariUtility {
    static func openLink(
        url: URL?,
        readerMode: Bool = false
    ) {
        guard let url = url else { return }
        let config = SFSafariViewController.Configuration()
        config.entersReaderIfAvailable = readerMode

        let safariViewController = SFSafariViewController(url: url, configuration: config)

        guard
            let window = WindowFinder.current(),
            let rootViewController = window.rootViewController
        else { return }
        
        //rootViewController.modalPresentationStyle = .fullScreen
        rootViewController.present(safariViewController, animated: true)
    }
}
