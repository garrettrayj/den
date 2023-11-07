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
}

class ReaderWebViewCoordinator: NSObject {
    let browserViewModel: BrowserViewModel
    let openURL: OpenURLAction

    init(browserViewModel: BrowserViewModel, openURL: OpenURLAction) {
        self.browserViewModel = browserViewModel
        self.openURL = openURL
    }
}

extension ReaderWebViewCoordinator: WKNavigationDelegate {
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
}

extension ReaderWebViewCoordinator: WKUIDelegate {
    // Open links in iFrames, e.g. YouTube embeds, in external app/browser
    func webView(
        _ webView: WKWebView,
        createWebViewWith configuration: WKWebViewConfiguration,
        for navigationAction: WKNavigationAction,
        windowFeatures: WKWindowFeatures
    ) -> WKWebView? {
        if !(navigationAction.targetFrame?.isMainFrame ?? false), let url = navigationAction.request.url {
            openURL(url)
        }

        return nil
    }
}

#if os(macOS)
extension ReaderWebView: NSViewRepresentable {
    func makeCoordinator() -> ReaderWebViewCoordinator {
        ReaderWebViewCoordinator(browserViewModel: browserViewModel, openURL: openURL)
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
        ReaderWebViewCoordinator(browserViewModel: browserViewModel, openURL: openURL)
    }

    func makeUIView(context: Context) -> WKWebView {
        makeWebView(context: context)
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
    }
}
#endif
