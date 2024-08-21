//
//  InAppSafari.swift
//  Den
//
//  Created by Garrett Johnson on 8/20/24.
//  Copyright © 2024 
//
//  SPDX-License-Identifier: MIT
//

#if os(iOS)
import SafariServices
import SwiftUI

@MainActor
struct InAppSafari {
    static func open(
        url: URL,
        environment: EnvironmentValues,
        accentColor: AccentColor,
        entersReaderIfAvailable: Bool
    ) {
        let configuration = SFSafariViewController.Configuration()
        configuration.entersReaderIfAvailable = entersReaderIfAvailable
        configuration.barCollapsingEnabled = false
        
        let safariViewController = SFSafariViewController(
            url: url,
            configuration: configuration
        )
        
        if let controlTintColor = accentColor.color {
            safariViewController.preferredControlTintColor = UIColor(
                cgColor: controlTintColor.resolve(in: environment).cgColor
            )
        }
        
        UIApplication.shared.firstKeyWindow?.rootViewController?.present(
            safariViewController,
            animated: true
        )
    }
}
#endif
