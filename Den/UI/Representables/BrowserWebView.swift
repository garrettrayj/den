//
//  WebBrowser.swift
//  Den
//
//  Created by Garrett Johnson on 10/2/23.
//  Copyright © 2023 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI
import WebKit

struct BrowserWebView {
    @ObservedObject var viewModel: BrowserViewModel

    func makeWebView(context: Context) -> WKWebView {
        let wkWebView = WKWebView()
        wkWebView.isInspectable = true

        viewModel.webView = wkWebView

        return wkWebView
    }
}

#if os(macOS)
extension BrowserWebView: NSViewRepresentable {
    func makeNSView(context: Context) -> WKWebView {
        makeWebView(context: context)
    }

    func updateNSView(_ nsView: WKWebView, context: Context) {
    }
}
#else
extension BrowserWebView: UIViewRepresentable {
     func makeUIView(context: Context) -> WKWebView {
         makeWebView(context: context)
     }

     func updateUIView(_ uiView: WKWebView, context: Context) {
     }
}
#endif
