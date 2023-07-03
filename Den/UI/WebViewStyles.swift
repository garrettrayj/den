//
//  WebViewStyles.swift
//  Den
//
//  Created by Garrett Johnson on 6/25/23.
//  Copyright © 2023 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import Foundation

final class WebViewStyles {
    var css: String = ""
    
    static let shared = WebViewStyles()
    
    init() {
        if
            let path = Bundle.main.path(forResource: "WebView", ofType: "css"),
            let webViewCSS = try? String(contentsOfFile: path).components(separatedBy: .newlines).joined()
        {
            self.css = webViewCSS
        }

        #if os(macOS)
        if
            let path = Bundle.main.path(forResource: "WebViewMac", ofType: "css"),
            let macCSS = try? String(contentsOfFile: path).components(separatedBy: .newlines).joined()
        {
            self.css += macCSS
        }
        #endif
    }
}
