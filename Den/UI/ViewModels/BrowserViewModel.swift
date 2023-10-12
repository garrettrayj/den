//
//  BrowserViewModel.swift
//  Den
//
//  Created by Garrett Johnson on 10/2/23.
//  Copyright © 2023 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI
import WebKit

class BrowserViewModel: NSObject, ObservableObject, WKNavigationDelegate, WKScriptMessageHandler {
    weak var webView: WKWebView? {
        didSet {
            webView?.navigationDelegate = self
            webView?.configuration.userContentController.add(self, name: "reader")

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
    @Published var showingReader = false
    @Published var mercuryObject: MercuryObject?
    @Published var useReaderAutomatically = false
    
    var isReaderable: Bool {
        mercuryObject != nil
    }

    func loadURL(url: URL?) {
        guard
            let url = url
        else {
            return
        }

        Task {
            await webView?.load(URLRequest(url: url))
        }
    }

    func loadBlank() {
        webView?.loadHTMLString("<html/>", baseURL: nil)
    }

    func goBack() {
        showingReader = false
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
        showingReader = false
        webView?.reload()
    }

    func showReader() {
        withAnimation {
            showingReader = true
        }
    }
    
    func hideReader() {
        withAnimation {
            showingReader = false
        }
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

    func userContentController(
        _ userContentController: WKUserContentController,
        didReceive message: WKScriptMessage
    ) {
        guard
            message.name == "reader",
            let jsonString = message.body as? String
        else { return }

        let jsonData = Data(jsonString.utf8)
        let decoder = JSONDecoder()

        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]

        decoder.dateDecodingStrategy = .custom({ decoder in
            let container = try decoder.singleValueContainer()
            let dateString = try container.decode(String.self)

            if let date = formatter.date(from: dateString) {
                return date
            }

            throw DecodingError.dataCorruptedError(
                in: container,
                debugDescription: "Cannot decode date string \(dateString)"
            )
        })

        mercuryObject = try? decoder.decode(MercuryObject.self, from: jsonData)

        if useReaderAutomatically {
            showReader()
        }
    }
}
