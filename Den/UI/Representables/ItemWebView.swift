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
    @Environment(\.profileTint) private var profileTint
    @Environment(\.useSystemBrowser) private var useSystemBrowser

    var html: String?
    var title: String
    var baseURL: URL?
    var tint: Color?

    @State var webView = CustomWebView(frame: .zero, configuration: WKWebViewConfiguration())

    func makeCoordinator() -> Coordinator {
        Coordinator(profileTint: profileTint, useSystemBrowser: useSystemBrowser)
    }

    private func loadContent() {
        guard let html = html else { return }

        let htmlStart = """
        <html><head>\
        <title>\(title)</title>\
        <meta name=\"viewport\" content=\"width=device-width, initial-scale=1.0, shrink-to-fit=no, user-scalable=no\">\
        <style>\(getStylesString())</style>
        </head><body>
        """
        let htmlEnd = "</body></html>"
        let htmlString = "\(htmlStart)\(html)\(htmlEnd)"

        webView.loadHTMLString(htmlString, baseURL: baseURL)
    }

    private func getStylesString() -> String {
        let css = WebViewStyles.shared.css.replacingOccurrences(
            of: "$TINT_COLOR",
            with: profileTint.hexString ?? "blue"
        )
        return css
    }

    class Coordinator: NSObject, WKNavigationDelegate {
        let profileTint: Color
        let useSystemBrowser: Bool

        var cancellable: Cancellable?

        init(profileTint: Color, useSystemBrowser: Bool) {
            self.profileTint = profileTint
            self.useSystemBrowser = useSystemBrowser
        }

        func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
            cancellable = DispatchQueue.main.schedule(
                after: .init(.now() + 0.1),
                interval: 1
            ) {
                webView.evaluateJavaScript("document.readyState", completionHandler: { (complete, _) in
                    if complete != nil {
                        webView.evaluateJavaScript("document.body.scrollHeight", completionHandler: { (height, _) in

                            guard let height = height as? CGFloat else { return }
                            webView.frame.size.height = height
                            webView.removeConstraints(webView.constraints)
                            webView.heightAnchor.constraint(equalToConstant: height).isActive = true
                        })
                    }
                })

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

                #if os(macOS)
                NSWorkspace.shared.open(url)
                #else
                if useSystemBrowser {
                    UIApplication.shared.open(url)
                } else {
                    SafariUtility.openLink(url: url, controlTintColor: profileTint)
                }
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
        webView.scrollView.isScrollEnabled = false
        webView.scrollView.bounces = false
        webView.navigationDelegate = context.coordinator
        webView.isOpaque = false
        if #available(macCatalyst 16.4, iOS 16.4, *) {
            webView.isInspectable = true
        }

        return webView
    }

    func updateUIView(_ webView: WKWebView, context: Context) {
        loadContent()
        return
    }
}
#else
extension ItemWebView: NSViewRepresentable {
    func makeNSView(context: Context) -> WKWebView {
        webView.navigationDelegate = context.coordinator
        webView.isInspectable = true
        webView.setValue(false, forKey: "drawsBackground")

        return webView
    }

    func updateNSView(_ webView: WKWebView, context: Context) {
        loadContent()
        return
    }
}
#endif
