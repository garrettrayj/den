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
    @Environment(\.self) private var environment
    @Environment(\.userTint) private var userTint

    @ObservedObject var browserViewModel: BrowserViewModel

    var publishedDate: Date?
    var byline: String?

    var html: String {
        guard
            let mercuryObject = browserViewModel.mercuryObject,
            let title = mercuryObject.title,
            let content = mercuryObject.content
        else {
            return "<html><body><p>Reader Unavailable</p></body></html>"
        }

        var html = """
            <html>
            <head>
            <title>Den Reader</title>
            <meta name="viewport" content="width=device-width, initial-scale=1.0, shrink-to-fit=no, user-scalable=no" />
            <style>\(getStyles())</style>
            </head>
            <body>
            <header>
            <h1 id="den-title">\(title)</h1>
        """

        if let byline = byline ?? mercuryObject.author {
            html += "<p id=\"den-author\">\(byline)</p>"
        }

        if let date = publishedDate ?? mercuryObject.date_published {
            html += """
            <p id="den-date-published">
                \(date.formatted(date: .complete, time: .shortened))
                (\(date.formatted(.relative(presentation: .numeric))))
            </p>
            """
        }

        if
            let leadImageURL = mercuryObject.lead_image_url,
            !content.prefix(600).contains("<img") && !content.prefix(600).contains("<picture")
        {
            html += "<img src=\"\(leadImageURL.absoluteString)\" />"
        }

        html += """
            </header>
            <main>
            \(content)
            </body>
            </html>
        """

        return html
    }

    func makeWebView(context: Context) -> WKWebView {
        let wkWebView = WKWebView()
        wkWebView.isInspectable = true
        wkWebView.navigationDelegate = context.coordinator

        addReaderInitScript(wkWebView.configuration.userContentController)

        wkWebView.loadHTMLString(html, baseURL: browserViewModel.url)

        return wkWebView
    }

    private func getStyles() -> String {
        guard
            let path = Bundle.main.path(forResource: "Reader", ofType: "css"),
            var styles = try? String(contentsOfFile: path)
        else {
            return ""
        }

        #if os(macOS)
        if
            let path = Bundle.main.path(forResource: "ReaderMac", ofType: "css"),
            let macStyles = try? String(contentsOfFile: path).components(separatedBy: .newlines).joined()
        {
            styles += macStyles
        }
        #endif

        return styles.replacingOccurrences(
            of: "$TINT_COLOR",
            with: userTint?.hexString(environment: environment) ?? "accentcolor"
        )
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
            let browserActions: Set<WKNavigationType> = [.linkActivated, .formSubmitted]
            
            if
                let url = navigationAction.request.url,
                browserActions.contains(navigationAction.navigationType)
            {
                decisionHandler(.cancel)
                browserViewModel.showingReader = false
                browserViewModel.loadURL(url: url)
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
