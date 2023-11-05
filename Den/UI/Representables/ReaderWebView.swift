//
//  ReaderWebView.swift
//  Den
//
//  Created by Garrett Johnson on 10/8/23.
//  Copyright © 2023 Garrett Johnson
//

import SwiftUI
import WebKit

struct ReaderWebView {
    @Environment(\.openURL) private var openURL

    @ObservedObject var browserViewModel: BrowserViewModel

    func makeWebView(context: Context) -> WKWebView {
        let wkWebView = WKWebView()
        wkWebView.isInspectable = true
        wkWebView.uiDelegate = context.coordinator
        wkWebView.navigationDelegate = context.coordinator
        wkWebView.configuration.defaultWebpagePreferences.preferredContentMode = .mobile
        #if os(iOS)
        wkWebView.scrollView.clipsToBounds = false
        #endif

        browserViewModel.readerWebView = wkWebView

        return wkWebView
    }

    class Coordinator: NSObject, WKNavigationDelegate, WKUIDelegate {
        let browserViewModel: BrowserViewModel
        let openURL: OpenURLAction

        init(browserViewModel: BrowserViewModel, openURL: OpenURLAction) {
            self.browserViewModel = browserViewModel
            self.openURL = openURL
        }

        func webView(
            _ webView: WKWebView,
            decidePolicyFor navigationAction: WKNavigationAction,
            decisionHandler: @escaping (WKNavigationActionPolicy) -> Void
        ) {
            // Open external links in system browser
            if navigationAction.targetFrame == nil {
                if let url = navigationAction.request.url {
                    openURL(url)
                }
                decisionHandler(.cancel)
                return
            }

            // Open links for same frame in browser view
            let browserActions: Set<WKNavigationType> = [.linkActivated]
            if
                let url = navigationAction.request.url,
                browserActions.contains(navigationAction.navigationType)
            {
                Task {
                    await browserViewModel.loadURL(url: url)
                }
                decisionHandler(.cancel)
                return
            }
            
            decisionHandler(.allow)
        }
        
        // To open links in YouTube embeds
        func webView(
            _ webView: WKWebView,
            createWebViewWith configuration: WKWebViewConfiguration,
            for navigationAction: WKNavigationAction,
            windowFeatures: WKWindowFeatures
        ) -> WKWebView? {
            if !(navigationAction.targetFrame?.isMainFrame ?? false) {
                webView.load(navigationAction.request)
            }
            return nil
        }
    }
}

#if os(macOS)
extension ReaderWebView: NSViewRepresentable {
    func makeCoordinator() -> Coordinator {
        Coordinator(browserViewModel: browserViewModel, openURL: openURL)
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
        Coordinator(browserViewModel: browserViewModel, openURL: openURL)
    }

    func makeUIView(context: Context) -> WKWebView {
        makeWebView(context: context)
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
    }
}
#endif
