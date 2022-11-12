//
//  WebView.swift
//  Den
//
//  Created by Garrett Johnson on 7/10/22.
//  Copyright © 2022 Garrett Johnson. All rights reserved.
//

import Combine
import SwiftUI
import WebKit

class CustomWebView: WKWebView {
    init(frame: CGRect) {
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

        super.init(frame: frame, configuration: configuration)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override var intrinsicContentSize: CGSize {
        return self.scrollView.contentSize
    }
}

struct WebView: UIViewRepresentable {
    let html: String
    let title: String?
    let baseURL: URL?

    func makeUIView(context: Context) -> WKWebView {
        let webView = CustomWebView(
            frame: CGRect(origin: .zero, size: CGSize())
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

        return webView
    }

    func updateUIView(_ webView: WKWebView, context: Context) {
        webView.invalidateIntrinsicContentSize()
    }

    class Coordinator: NSObject, WKNavigationDelegate {
        var cancellable: Cancellable?
        
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            cancellable = DispatchQueue.main.schedule(
                after: DispatchQueue.SchedulerTimeType(.now() + 0.1),
                interval: 1
            ) {
                webView.invalidateIntrinsicContentSize()
            }
        }

        func webView(
            _ webView: WKWebView,
            decidePolicyFor navigationAction: WKNavigationAction,
            decisionHandler: @escaping (WKNavigationActionPolicy) -> Void
        ) {
            let browserActions: Set<WKNavigationType> = [.linkActivated]
            if let url = navigationAction.request.url, browserActions.contains(navigationAction.navigationType) {
                decisionHandler(.cancel)
                UIApplication.shared.open(url)
            } else {
                decisionHandler(.allow)
            }
        }
        
        deinit {
            cancellable?.cancel()
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
}
