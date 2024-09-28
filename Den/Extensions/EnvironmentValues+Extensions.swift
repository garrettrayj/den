//
//  EnvironmentValues+Extensions.swift
//  Den
//
//  Created by Garrett Johnson on 8/25/24.
//  Copyright © 2024 
//

import SwiftUI
#if os(iOS)
import SafariServices
#endif

private struct AccentColorKey: EnvironmentKey {
    static let defaultValue: Color? = nil
}

private struct HideReadKey: EnvironmentKey {
    static let defaultValue: Bool = false
}

private struct PreferredViewerKey: EnvironmentKey {
    static let defaultValue: ViewerOption = .builtInViewer
}

private struct ShowUnreadCountsKey: EnvironmentKey {
    static let defaultValue: Bool = true
}

extension EnvironmentValues {
    var accentColor: Color? {
        get { self[AccentColorKey.self] }
        set { self[AccentColorKey.self] = newValue }
    }
    
    var accentHexString: String? {
        self.accentColor?.hexString(environment: self)
    }
    
    var hideRead: Bool {
        get { self[HideReadKey.self] }
        set { self[HideReadKey.self] = newValue }
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
    
    var operatingSystem: OperatingSystem {
        #if os(macOS)
        .macOS
        #else
        .iOS
        #endif
    }
    
    var preferredViewer: ViewerOption {
        get { self[PreferredViewerKey.self] }
        set { self[PreferredViewerKey.self] = newValue }
    }
    
    var showUnreadCounts: Bool {
        get { self[ShowUnreadCountsKey.self] }
        set { self[ShowUnreadCountsKey.self] = newValue }
    }
}
