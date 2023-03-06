//
//  WebView.swift
//  Den
//
//  Created by Garrett Johnson on 7/10/22.
//  Copyright © 2022 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI
import WebKit

struct WebView: UIViewRepresentable {
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @Environment(\.contentFontFamily) private var contentFontFamily

    let html: String
    let title: String?
    let baseURL: URL?

    @ObservedObject var profile: Profile

    func makeUIView(context: Context) -> WKWebView {
        let configuration = WKWebViewConfiguration()

        let webpagePreferences = WKWebpagePreferences()

        if
            let path = Bundle.main.path(forResource: "WebViewStyles", ofType: "css"),
            let cssString = try? String(contentsOfFile: path).components(separatedBy: .newlines).joined()
                .replacingOccurrences(of: "a {    color: -apple-system-blue", with: """
                @media (prefers-color-scheme: dark) { a { color:
                \(self.hexStringFromColor(color: UIColor(
                    profile.tintColor ?? Color.blue)
                        .adjust(brightness: 1.0, saturation: 0.85)));}}
                @media (prefers-color-scheme: light) { a { color:
                \(self.hexStringFromColor(color: UIColor(
                    profile.tintColor ?? Color.blue)
                        .adjust(brightness: 0.9, saturation: 1)));}}
                a { text-decoration: none
                """)
                .components(separatedBy: .newlines).joined()
                .replacingOccurrences(of: "-apple-system-purple;}", with: """
                -apple-system-purple;} a:hover{text-decoration: underline}
                """) {
            let source = """
            var style = document.createElement('style');
            style.innerHTML = '\(cssString)';
            document.head.appendChild(style);
            document.body.style.fontFamily='\(contentFontFamily)';
            document.body.style.fontSize='\(dynamicTypeSize.fontScale * 100)%';
            document.body.style.lineHeight='\(dynamicTypeSize.fontScale * 140)%';
            """

            let userScript = WKUserScript(source: source, injectionTime: .atDocumentEnd, forMainFrameOnly: true)
            let userContentController = WKUserContentController()
            userContentController.addUserScript(userScript)
            configuration.userContentController = userContentController
            configuration.defaultWebpagePreferences = webpagePreferences
        }

        let webView = ResizingWebView(frame: .zero, configuration: configuration)
        webView.scrollView.isScrollEnabled = false
        webView.scrollView.bounces = true
        webView.navigationDelegate = context.coordinator

        let htmlStart = """
        <HTML><HEAD>\
        <title>\(title ?? "Untitled")</title>\
        <meta name=\"viewport\" content=\"width=device-width, initial-scale=1.0, shrink-to-fit=no, user-scalable=no\">\
        </HEAD><BODY>
        """
        let htmlEnd = "</BODY></HTML>"
        let htmlString = "\(htmlStart)\(html)\(htmlEnd)"

        webView.loadHTMLString(htmlString, baseURL: baseURL)

        webView.invalidateIntrinsicContentSize()

        return webView
    }

    func updateUIView(_ webView: WKWebView, context: Context) {
        webView.invalidateIntrinsicContentSize()
    }

    class Coordinator: NSObject, WKNavigationDelegate {
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            webView.invalidateIntrinsicContentSize()
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
    }

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    func hexStringFromColor(color: UIColor) -> String {
        let components = color.cgColor.components
        let red: CGFloat = components?[0] ?? 0.0
        let green: CGFloat = components?[1] ?? 0.0
        let blue: CGFloat = components?[2] ?? 0.0

        let hexString = String.init(
            format: "#%02lX%02lX%02lX",
                    lroundf(Float(red * 255)),
                    lroundf(Float(green * 255)),
                    lroundf(Float(blue * 255))
        )
        return hexString
     }
}
