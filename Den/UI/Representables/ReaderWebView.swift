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
    @Environment(\.openURL) private var openURL
    
    @EnvironmentObject private var downloadManager: DownloadManager

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
    
    func makeCoordinator() -> ReaderWebViewCoordinator {
        ReaderWebViewCoordinator(
            browserViewModel: browserViewModel,
            openURL: openURL,
            downloadManager: downloadManager
        )
    }
}

class ReaderWebViewCoordinator: NSObject {
    let browserViewModel: BrowserViewModel
    let openURL: OpenURLAction
    let downloadManager: DownloadManager

    init(
        browserViewModel: BrowserViewModel,
        openURL: OpenURLAction,
        downloadManager: DownloadManager
    ) {
        self.browserViewModel = browserViewModel
        self.openURL = openURL
        self.downloadManager = downloadManager
    }
}

extension ReaderWebViewCoordinator: WKNavigationDelegate {
    func webView(
        _ webView: WKWebView,
        decidePolicyFor navigationAction: WKNavigationAction,
        decisionHandler: @escaping (WKNavigationActionPolicy) -> Void
    ) {
        if navigationAction.shouldPerformDownload {
            decisionHandler(.download)
            return
        }
    
        // Open external links in system browser
        if navigationAction.targetFrame == nil {
            if let url = navigationAction.request.url {
                openURL(url)
            }
            decisionHandler(.cancel)
            return
        }
        
        // Download downloadable file extensions to prevent "Frame load interrupted" error
        if let url = navigationAction.targetFrame?.request.url,
           Downloadable.fileExtensions.contains(url.pathExtension) {
            decisionHandler(.download)
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
    
    func webView(
        _ webView: WKWebView,
        decidePolicyFor navigationResponse: WKNavigationResponse,
        decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void
    ) {
        if navigationResponse.canShowMIMEType {
            decisionHandler(.allow)
        } else {
            decisionHandler(.download)
        }
    }
    
    func webView(
        _ webView: WKWebView,
        navigationAction: WKNavigationAction,
        didBecome download: WKDownload
    ) {
        download.delegate = self.downloadManager
    }
        
    func webView(
        _ webView: WKWebView,
        navigationResponse: WKNavigationResponse,
        didBecome download: WKDownload
    ) {
        download.delegate = self.downloadManager
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
    func makeNSView(context: Context) -> WKWebView {
        makeWebView(context: context)
    }

    func updateNSView(_ nsView: WKWebView, context: Context) {
    }
}
#else
extension ReaderWebView: UIViewRepresentable {
    func makeUIView(context: Context) -> WKWebView {
        makeWebView(context: context)
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
    }
}
#endif
