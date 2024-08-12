//
//  WebBrowser.swift
//  Den
//
//  Created by Garrett Johnson on 10/2/23.
//  Copyright © 2023 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI
import WebKit

@MainActor
struct BrowserWebView {
    @Environment(\.openURL) private var openURL
    
    @EnvironmentObject private var downloadManager: DownloadManager
    
    @ObservedObject var browserViewModel: BrowserViewModel
    
    func makeWebView(context: Context) -> WKWebView {
        let configuration = WKWebViewConfiguration()
        configuration.mediaTypesRequiringUserActionForPlayback = .all
        configuration.userContentController.add(context.coordinator, name: "reader")
        
        if let mercuryScript, let parseForReaderScript {
            configuration.userContentController.addUserScript(mercuryScript)
            configuration.userContentController.addUserScript(parseForReaderScript)
        }
        
        let wkWebView = DenWebView(frame: .zero, configuration: configuration)
        wkWebView.isInspectable = true
        wkWebView.navigationDelegate = context.coordinator
        wkWebView.uiDelegate = context.coordinator

        browserViewModel.browserWebView = wkWebView

        return wkWebView
    }
    
    func makeCoordinator() -> BrowserWebViewCoordinator {
        BrowserWebViewCoordinator(
            browserViewModel: browserViewModel,
            downloadManager: downloadManager,
            openURL: openURL
        )
    }

    private var mercuryScript: WKUserScript? {
        guard
            let path = Bundle.main.path(forResource: "Mercury", ofType: "js"),
            let script = try? String(contentsOfFile: path, encoding: .utf8)
        else {
            return nil
        }

        return WKUserScript(
            source: script,
            injectionTime: .atDocumentStart,
            forMainFrameOnly: true
        )
    }

    private var parseForReaderScript: WKUserScript? {
        guard
            let path = Bundle.main.path(forResource: "ParseForReader", ofType: "js"),
            let script = try? String(contentsOfFile: path, encoding: .utf8)
        else {
            return nil
        }

        return WKUserScript(
            source: script,
            injectionTime: .atDocumentStart,
            forMainFrameOnly: true
        )
    }
}

final class BrowserWebViewCoordinator: NSObject {
    let browserViewModel: BrowserViewModel
    let downloadManager: DownloadManager
    let openURL: OpenURLAction

    init(
        browserViewModel: BrowserViewModel,
        downloadManager: DownloadManager,
        openURL: OpenURLAction
    ) {
        self.browserViewModel = browserViewModel
        self.downloadManager = downloadManager
        self.openURL = openURL
    }
}

extension BrowserWebViewCoordinator: WKNavigationDelegate {
    func webView(
        _ webView: WKWebView,
        didFailProvisionalNavigation navigation: WKNavigation!,
        withError error: Error
    ) {
        Task {
            await MainActor.run {
                if let urlError = error as? URLError {
                    guard let failingURL = urlError.failingURL else { return }
                    let errorHTML = WebViewError(error: error).html
                    
                    webView.loadSimulatedRequest(
                        URLRequest(url: failingURL),
                        responseHTML: errorHTML
                    )
                }
            }
        }
    }
    
    func webView(
        _ webView: WKWebView,
        decidePolicyFor navigationAction: WKNavigationAction,
        decisionHandler: @escaping @MainActor (WKNavigationActionPolicy) -> Void
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

        decisionHandler(.allow)
    }
    
    func webView(
        _ webView: WKWebView,
        decidePolicyFor navigationResponse: WKNavigationResponse,
        decisionHandler: @escaping @MainActor (WKNavigationResponsePolicy) -> Void
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

extension BrowserWebViewCoordinator: WKScriptMessageHandler {
    func userContentController(
        _ userContentController: WKUserContentController,
        didReceive message: WKScriptMessage
    ) {
        guard
            message.name == "reader",
            let jsonString = message.body as? String
        else { return }
        
        let browserViewModel = browserViewModel
        
        Task {
            await MainActor.run {
                let jsonData = Data(jsonString.utf8)
                let decoder = JSONDecoder()

                decoder.dateDecodingStrategy = .custom({ decoder in
                    let standardFormatter = ISO8601DateFormatter()
                    standardFormatter.formatOptions = [.withInternetDateTime]
                    
                    let fractionalSecondsFormatter = ISO8601DateFormatter()
                    standardFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
                    
                    let container = try decoder.singleValueContainer()
                    let dateString = try container.decode(String.self)

                    if let date = standardFormatter.date(from: dateString) {
                        return date
                    } else if let date = fractionalSecondsFormatter.date(from: dateString) {
                        return date
                    }

                    throw DecodingError.dataCorruptedError(
                        in: container,
                        debugDescription: "Cannot decode date string \(dateString)"
                    )
                })

                if
                    let mercuryObject = try? decoder.decode(MercuryObject.self, from: jsonData),
                    mercuryObject.title != nil && mercuryObject.title != "",
                    mercuryObject.content != nil && mercuryObject.content != ""
                {
                    browserViewModel.mercuryObject = mercuryObject
                    browserViewModel.isReaderable = true

                    if browserViewModel.useReaderAutomatically {
                        browserViewModel.showReader()
                    }
                } else {
                    browserViewModel.mercuryObject = nil
                    browserViewModel.isReaderable = false
                    browserViewModel.showingReader = false
                }
            }
        }
    }
}

extension BrowserWebViewCoordinator: WKUIDelegate {
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
extension BrowserWebView: NSViewRepresentable {
    func makeNSView(context: Context) -> WKWebView {
        makeWebView(context: context)
    }

    func updateNSView(_ nsView: WKWebView, context: Context) {
    }
}
#else
extension BrowserWebView: UIViewRepresentable {
    func makeUIView(context: Context) -> WKWebView {
        makeWebView(context: context)
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
    }
}
#endif
