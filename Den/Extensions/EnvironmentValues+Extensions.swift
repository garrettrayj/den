//
//  Environment.swift
//  Den
//
//  Created by Garrett Johnson on 10/7/22.
//  Copyright © 2022 Garrett Johnson
//
//  SPDX-License-Identifier: NONE
//

import CoreData
import SwiftUI

private struct UserTintKey: EnvironmentKey {
    static let defaultValue: Color? = nil
}

private struct UseSystemBrowserKey: EnvironmentKey {
    static let defaultValue: Bool = true
}

extension EnvironmentValues {
    var faviconSize: CGSize {
        switch self.imageScale {
        case .small:
            return ImageSize.smallFavicon
        case .medium:
            return ImageSize.mediumFavicon
        case .large:
            return ImageSize.largeFavicon
        @unknown default:
            return ImageSize.mediumFavicon
        }
    }
    
    var faviconPixelSize: CGSize {
        faviconSize.scaled(by: displayScale)
    }

    var largeThumbnailSize: CGSize {
        ImageSize.largeThumbnail.scaled(by: dynamicTypeSize.layoutScalingFactor)
    }

    var largeThumbnailPixelSize: CGSize {
        largeThumbnailSize.scaled(by: displayScale)
    }
    
    /// Used for NavigationSplitView detail column `.navigationSplitViewColumnWidth()`
    /// and `.frame(minWidth:)` on views with an inspector (to prevent over minimizing content)
    var minDetailColumnWidth: CGFloat { 320 }

    var smallThumbnailSize: CGSize {
        ImageSize.smallThumbnail.scaled(by: dynamicTypeSize.layoutScalingFactor)
    }

    var smallThumbnailPixelSize: CGSize {
        smallThumbnailSize.scaled(by: displayScale)
    }

    var userTint: Color? {
        get { self[UserTintKey.self] }
        set { self[UserTintKey.self] = newValue }
    }
    
    var userTintHex: String? {
        userTint?.hexString(environment: self)
    }

    var useSystemBrowser: Bool {
        get { self[UseSystemBrowserKey.self] }
        set { self[UseSystemBrowserKey.self] = newValue }
    }
}
