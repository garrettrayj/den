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

struct ItemWebView {
    @Environment(\.openURL) private var openURL
    @Environment(\.useSystemBrowser) private var useSystemBrowser

    var content: String
    var title: String
    var baseURL: URL?
    var tintColor: Color?

    func makeCoordinator() -> Coordinator {
        Coordinator(tintColor: tintColor, useSystemBrowser: useSystemBrowser, openURL: openURL)
    }

    var html: String {
        """
        <html>
        <head>
        <title>\(title)</title>
        <meta name="viewport" content="width=device-width, initial-scale=1.0, shrink-to-fit=no, user-scalable=no" />
        <style>\(getStylesString())</style>
        <script>
            const observer = new ResizeObserver(entries => {
                for (const entry of entries) {
                    window.webkit.messageHandlers.resized.postMessage(document.body.scrollHeight);
                }
            });

            window.addEventListener("DOMContentLoaded", (event) => {
                observer.observe(document.body);
            });
        </script>
        </head>
        <body>
        \(content)
        </body>
        </html>
        """
    }

    private func getStylesString() -> String {
        let css = WebViewStyles.shared.css.replacingOccurrences(
            of: "$TINT_COLOR",
            with: tintColor?.hexString ?? "blue"
        )
        return css
    }

    class Coordinator: NSObject, WKNavigationDelegate, WKScriptMessageHandler {
        let tintColor: Color?
        let useSystemBrowser: Bool
        let openURL: OpenURLAction

        init(tintColor: Color?, useSystemBrowser: Bool, openURL: OpenURLAction) {
            self.tintColor = tintColor
            self.useSystemBrowser = useSystemBrowser
            self.openURL = openURL
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

                #if os(macOS)
                openURL(url)
                #else
                if useSystemBrowser {
                    openURL(url)
                } else {
                    BuiltInBrowser.openURL(url: url, controlTintColor: tintColor)
                }
                #endif
            } else {
                decisionHandler(.allow)
            }
        }

        func userContentController(
            _ userContentController: WKUserContentController,
            didReceive message: WKScriptMessage
        ) {
            guard
                let webView = message.webView,
                let height = message.body as? CGFloat
            else { return }

            #if os(macOS)
            webView.frame.size.height = height
            webView.removeConstraints(webView.constraints)
            webView.heightAnchor.constraint(equalToConstant: height).isActive = true
            #else
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                webView.invalidateIntrinsicContentSize()
            }
            #endif
        }
    }

    class CustomWebView: WKWebView {
        #if os(macOS)
        override func scrollWheel(with theEvent: NSEvent) {
            nextResponder?.scrollWheel(with: theEvent)
            return
        }
        #endif

        #if os(iOS)
        override var intrinsicContentSize: CGSize {
            self.scrollView.contentSize
        }
        #endif
    }
}

#if os(iOS)
extension ItemWebView: UIViewRepresentable {
    func makeUIView(context: Context) -> WKWebView {
        let configuration = WKWebViewConfiguration()
        configuration.userContentController.add(context.coordinator, name: "resized")

        let webView = CustomWebView(frame: .zero, configuration: configuration)

        webView.scrollView.isScrollEnabled = false
        webView.scrollView.bounces = false
        webView.navigationDelegate = context.coordinator
        webView.isOpaque = false
        if #available(iOS 16.4, *) {
            webView.isInspectable = true
        }

        webView.loadHTMLString(html, baseURL: baseURL)

        return webView
    }

    func updateUIView(_ webView: WKWebView, context: Context) {
        return
    }
}
#else
extension ItemWebView: NSViewRepresentable {
    func makeNSView(context: Context) -> WKWebView {
        let configuration = WKWebViewConfiguration()
        configuration.userContentController.add(context.coordinator, name: "resized")

        let webView = CustomWebView(frame: .zero, configuration: configuration)
        webView.navigationDelegate = context.coordinator
        webView.isInspectable = true
        webView.setValue(false, forKey: "drawsBackground")

        webView.loadHTMLString(html, baseURL: baseURL)

        return webView
    }

    func updateNSView(_ webView: WKWebView, context: Context) {
        return
    }
}
#endif
