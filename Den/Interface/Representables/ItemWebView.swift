//
//  ItemWebView.swift
//  Den
//
//  Created by Garrett Johnson on 7/10/22.
//  Copyright © 2022 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import Combine
import SwiftUI
import WebKit

struct ItemWebView: UIViewRepresentable {
    var html: String?
    var title: String
    var baseURL: URL?
    var tint: UIColor?

    @State var webView = CustomWebView(frame: .zero, configuration: WKWebViewConfiguration())

    func makeUIView(context: Context) -> WKWebView {
        webView.scrollView.isScrollEnabled = false
        webView.scrollView.bounces = false
        webView.navigationDelegate = context.coordinator

        loadContent()

        return webView
    }

    func updateUIView(_ webView: WKWebView, context: Context) {
        return
    }

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    private func loadContent() {
        guard let html = html else { return }

        let htmlStart = """
        <HTML><HEAD>\
        <title>\(title)</title>\
        <meta name=\"viewport\" content=\"width=device-width, initial-scale=1.0, shrink-to-fit=no, user-scalable=no\">\
        </HEAD><BODY>
        """
        let htmlEnd = "</BODY></HTML>"
        let htmlString = "\(htmlStart)\(html)\(htmlEnd)"

        webView.loadHTMLString(htmlString, baseURL: baseURL)

        if let cssString = getStylesString() {
            let source = """
            var style = document.createElement('style');
            style.innerHTML = '\(cssString)';
            document.head.appendChild(style);
            """

            let userScript = WKUserScript(source: source, injectionTime: .atDocumentEnd, forMainFrameOnly: true)
            webView.configuration.userContentController.addUserScript(userScript)
        }
    }

    private func getStylesString() -> String? {
        guard
            let path = Bundle.main.path(forResource: "WebViewStyles", ofType: "css"),
            let cssString = try? String(contentsOfFile: path)
                .replacingOccurrences(of: "$TINT_COLOR", with: tint?.hexString ?? UIColor.tintColor.hexString)
                .components(separatedBy: .newlines).joined()
        else { return nil }

        return cssString
    }

    class Coordinator: NSObject, WKNavigationDelegate {
        var cancellable: Cancellable?

        func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
            cancellable = DispatchQueue.main.schedule(
                after: .init(.now() + 0.1),
                interval: 1
            ) {
                webView.invalidateIntrinsicContentSize()
            }
        }

        func webViewWebContentProcessDidTerminate(_ webView: WKWebView) {
            cancellable?.cancel()
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

                #if targetEnvironment(macCatalyst)
                UIApplication.shared.open(url)
                #else
                SafariUtility.openLink(url: url)
                #endif
            } else {
                decisionHandler(.allow)
            }
        }

        deinit {
            cancellable?.cancel()
        }
    }

    class CustomWebView: WKWebView {
        override init(frame: CGRect, configuration: WKWebViewConfiguration) {
            super.init(frame: frame, configuration: configuration)
        }

        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

        override var intrinsicContentSize: CGSize {
            return self.scrollView.contentSize
        }
    }
}
