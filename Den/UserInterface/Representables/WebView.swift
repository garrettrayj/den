//
//  WebView.swift
//  Den
//
//  Created by Garrett Johnson on 7/10/22.
//  Copyright © 2022 Garrett Johnson. All rights reserved.
//

import SwiftUI
import WebKit

class ArticleWebView: WKWebView {
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
    @Binding var dynamicHeight: CGFloat

    var html: String
    var title: String?
    var baseURL: URL?

    var webView: WKWebView = ArticleWebView(frame: CGRect())

    func makeUIView(context: Context) -> WKWebView {
        webView.scrollView.isScrollEnabled = false
        webView.scrollView.bounces = false
        webView.navigationDelegate = context.coordinator

        let htmlStart = """
        <HTML><HEAD>\
        <title>\(title ?? "Untitled")</title>\
        <meta name=\"viewport\" content=\"width=device-width, initial-scale=1.0, shrink-to-fit=no\">\
        </HEAD><BODY>
        """
        let htmlEnd = "</BODY></HTML>"
        let htmlString = "\(htmlStart)\(html)\(htmlEnd)"

        webView.loadHTMLString(htmlString, baseURL: baseURL)

        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
    }

    class Coordinator: NSObject, WKNavigationDelegate {
        var parent: WebView

        init(_ parent: WebView) {
            self.parent = parent
        }

        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            webView.evaluateJavaScript("document.readyState", completionHandler: { (_, _) in
                DispatchQueue.main.async {
                    webView.invalidateIntrinsicContentSize()
                }
            })
        }

        func webView(
            _ webView: WKWebView,
            decidePolicyFor navigationAction: WKNavigationAction,
            decisionHandler: @escaping (WKNavigationActionPolicy) -> Void
        ) {
            let browserActions: Set<WKNavigationType> = [
                .linkActivated
            ]

            if let url = navigationAction.request.url, browserActions.contains(navigationAction.navigationType) {
                decisionHandler(.cancel)
                UIApplication.shared.open(url)
            } else {
                decisionHandler(.allow)
            }
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

}
