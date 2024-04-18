//
//  DenWebView.swift
//  Den
//
//  Created by Garrett Johnson on 4/18/24.
//  Copyright © 2024 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import Foundation
import WebKit

final class DenWebView: WKWebView {
    #if os(macOS)
    override func willOpenMenu(_ menu: NSMenu, with event: NSEvent) {
        for menuItem in menu.items {
            if menuItem.identifier?.rawValue == "WKMenuItemIdentifierDownloadImage" ||
                menuItem.identifier?.rawValue == "WKMenuItemIdentifierDownloadLinkedFile" {
                menuItem.isHidden = true
            }
        }
    }
    #endif
}
