//
//  EnvironmentValues+Extensions.swift
//  Den
//
//  Created by Garrett Johnson on 8/25/24.
//  Copyright © 2024 
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI
#if os(iOS)
import SafariServices
#endif

private struct AccentColorKey: EnvironmentKey {
    static let defaultValue: Color? = nil
}

extension EnvironmentValues {
    var accentColor: Color? {
        get { self[AccentColorKey.self] }
        set { self[AccentColorKey.self] = newValue }
    }
    
    var accentHexString: String? {
        self.accentColor?.hexString(environment: self)
    }
    
    #if os(iOS)
    var openURLInSafariView: @MainActor (_ url: URL, Bool?) -> Void {
        var preferredControlTintColor: UIColor?
        if let accentColor {
            preferredControlTintColor = UIColor(cgColor: accentColor.resolve(in: self).cgColor)
        }
        
        return { @MainActor url, entersReaderIfAvailable in
            let configuration = SFSafariViewController.Configuration()
            configuration.entersReaderIfAvailable = entersReaderIfAvailable ?? false
            configuration.barCollapsingEnabled = false
            
            let safariViewController = SFSafariViewController(
                url: url,
                configuration: configuration
            )
            
            safariViewController.preferredControlTintColor = preferredControlTintColor
            
            UIApplication.shared.firstKeyWindow?.rootViewController?.present(
                safariViewController,
                animated: true
            )
        }
    }
    #endif
}
