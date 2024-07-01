//
//  BasicWebView.swift
//  Den
//
//  Created by Garrett Johnson on 6/2/24.
//  Copyright © 2024 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import WebKit
import SwiftUI

@MainActor
struct BasicWebView {
    let htmlContent: String

    func makeWebView(context: Context) -> WKWebView {
        WKWebView()
    }
}

#if os(macOS)
extension BasicWebView: NSViewRepresentable {
    func makeNSView(context: Context) -> WKWebView {
        makeWebView(context: context)
    }

    func updateNSView(_ nsView: WKWebView, context: Context) {
        nsView.loadHTMLString(htmlContent, baseURL: nil)
    }
}
#else
extension BasicWebView: UIViewRepresentable {
    func makeUIView(context: Context) -> WKWebView {
        makeWebView(context: context)
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
        uiView.loadHTMLString(htmlContent, baseURL: nil)
    }
}
#endif
