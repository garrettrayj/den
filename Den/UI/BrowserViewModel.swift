//
//  BrowserViewModel.swift
//  Den
//
//  Created by Garrett Johnson on 10/2/23.
//  Copyright © 2023 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import Foundation
import WebKit

class BrowserViewModel: NSObject, ObservableObject, WKNavigationDelegate {
    weak var webView: WKWebView? {
        didSet {
            webView?.navigationDelegate = self
            Task {
                await MainActor.run {
                    webView?.publisher(for: \.canGoBack).assign(to: &$canGoBack)
                    webView?.publisher(for: \.canGoForward).assign(to: &$canGoForward)
                    webView?.publisher(for: \.estimatedProgress).assign(to: &$estimatedProgress)
                    webView?.publisher(for: \.url).assign(to: &$url)
                }
            }
        }
    }

    @Published var url: URL?
    @Published var estimatedProgress: Double = 0
    @Published var canGoBack = false
    @Published var canGoForward = false
    @Published var isLoading = true
    @Published var browserError: Error?

    func loadURL() {
        if let url = url {
            webView?.load(URLRequest(url: url))
        }
    }
    
    func loadBlank() {
        webView?.loadHTMLString("<html/>", baseURL: nil)
    }

    func goBack() {
        webView?.goBack()
    }

    func goForward() {
        webView?.goForward()
    }

    func stop() {
        webView?.stopLoading()
        isLoading = false
    }

    func reload() {
        webView?.reload()
    }

    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        isLoading = true
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        isLoading = false
    }

    func webView(
        _ webView: WKWebView,
        didFailProvisionalNavigation navigation: WKNavigation!,
        withError error: Error
    ) {
        isLoading = false
        browserError = error
    }
}
