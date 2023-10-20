//
//  ReaderWebView.swift
//  Den
//
//  Created by Garrett Johnson on 10/8/23.
//  Copyright © 2023 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI
import WebKit

struct ReaderWebView {
    @ObservedObject var browserViewModel: BrowserViewModel

    func makeWebView(context: Context) -> WKWebView {
        let wkWebView = WKWebView()
        wkWebView.isInspectable = true
        wkWebView.navigationDelegate = context.coordinator
        wkWebView.configuration.defaultWebpagePreferences.preferredContentMode = .mobile

        addReaderInitScript(wkWebView.configuration.userContentController)

        browserViewModel.readerWebView = wkWebView

        return wkWebView
    }

    private func addReaderInitScript(_ contentController: WKUserContentController) {
        guard
            let path = Bundle.main.path(forResource: "ReaderInit", ofType: "js"),
            let script = try? String(contentsOfFile: path)
        else {
            return
        }

        let userScript = WKUserScript(
            source: script,
            injectionTime: .atDocumentStart,
            forMainFrameOnly: true
        )

        contentController.addUserScript(userScript)
    }

    class Coordinator: NSObject, WKNavigationDelegate {
        let browserViewModel: BrowserViewModel

        init(browserViewModel: BrowserViewModel) {
            self.browserViewModel = browserViewModel
        }

        func webView(
            _ webView: WKWebView,
            decidePolicyFor navigationAction: WKNavigationAction,
            decisionHandler: @escaping (WKNavigationActionPolicy) -> Void
        ) {
            let browserActions: Set<WKNavigationType> = [.linkActivated]

            if
                let url = navigationAction.request.url,
                browserActions.contains(navigationAction.navigationType)
            {
                decisionHandler(.cancel)
                
                Task {
                    await browserViewModel.loadURL(url: url)
                }
            } else {
                decisionHandler(.allow)
            }
        }
    }
}

#if os(macOS)
extension ReaderWebView: NSViewRepresentable {
    func makeCoordinator() -> Coordinator {
        Coordinator(browserViewModel: browserViewModel)
    }

    func makeNSView(context: Context) -> WKWebView {
        makeWebView(context: context)
    }

    func updateNSView(_ nsView: WKWebView, context: Context) {
    }
}
#else
extension ReaderWebView: UIViewRepresentable {
    func makeCoordinator() -> Coordinator {
        Coordinator(browserViewModel: browserViewModel)
    }

    func makeUIView(context: Context) -> WKWebView {
        makeWebView(context: context)
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
    }
}
#endif
