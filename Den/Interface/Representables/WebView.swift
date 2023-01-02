//
//  WebView.swift
//  Den
//
//  Created by Garrett Johnson on 7/10/22.
//  Copyright © 2022 Garrett Johnson
//

import Combine
import SwiftUI
import WebKit

/// Override and extend WKWebView with an `intrinsicContentSize` that matches scrollview
/// and automatic size invalidation on an interval.
/// While most resize bubbling needs should be covered by other calls to `invalidateIntrinsicContentSize()`,
/// scheduled invalidation handles edge cases such as JavaScript, e.g. Twitter widgets, adjusting content
/// size unpredictably.
class CustomWebView: WKWebView {
    var cancellable: Cancellable?

    override init(frame: CGRect, configuration: WKWebViewConfiguration) {
        super.init(frame: frame, configuration: configuration)

        cancellable = DispatchQueue.main.schedule(
            after: .init(.now() + 0.25),
            interval: 1
        ) {
            self.invalidateIntrinsicContentSize()
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override var intrinsicContentSize: CGSize {
        return self.scrollView.contentSize
    }

    deinit {
        cancellable?.cancel()
    }
}

struct WebView: UIViewRepresentable {
    let html: String
    let title: String?
    let baseURL: URL?

    func makeUIView(context: Context) -> WKWebView {
        let configuration = WKWebViewConfiguration()

        if
            let path = Bundle.main.path(forResource: "WebViewStyles", ofType: "css"),
            let cssString = try? String(contentsOfFile: path).components(separatedBy: .newlines).joined()
        {
            let source = """
            var style = document.createElement('style');
            style.innerHTML = '\(cssString)';
            document.head.appendChild(style);
            """
            let userScript = WKUserScript(source: source, injectionTime: .atDocumentEnd, forMainFrameOnly: true)
            let userContentController = WKUserContentController()
            userContentController.addUserScript(userScript)
            configuration.userContentController = userContentController
        }

        let webView = CustomWebView(
            frame: CGRect(origin: .zero, size: CGSize(width: 800, height: 600)),
            configuration: configuration
        )
        webView.scrollView.isScrollEnabled = false
        webView.scrollView.bounces = false
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
}
