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
    
    @Environment(DownloadManager.self) private var downloadManager
    
    @Bindable var browserViewModel: BrowserViewModel
    
    func makeWebView(context: Context) -> WKWebView {
        let wkWebView = DenWebView()
        wkWebView.isInspectable = true
        wkWebView.navigationDelegate = context.coordinator
        wkWebView.uiDelegate = context.coordinator
        wkWebView.configuration.mediaTypesRequiringUserActionForPlayback = .all
        wkWebView.configuration.userContentController.add(context.coordinator, name: "reader")

        addMercuryScript(wkWebView.configuration.userContentController)
        addParseForReaderScript(wkWebView.configuration.userContentController)

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

    private func addMercuryScript(_ contentController: WKUserContentController) {
        guard
            let path = Bundle.main.path(forResource: "Mercury", ofType: "js"),
            let script = try? String(contentsOfFile: path, encoding: .utf8)
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

    private func addParseForReaderScript(_ contentController: WKUserContentController) {
        guard
            let path = Bundle.main.path(forResource: "ParseForReader", ofType: "js"),
            let script = try? String(contentsOfFile: path, encoding: .utf8)
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
}

@MainActor
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
        if let urlError = error as? URLError {
            guard let failingURL = urlError.failingURL else { return }
            let errorHTML = WebViewError(error: error).html
            
            webView.loadSimulatedRequest(
                URLRequest(url: failingURL),
                responseHTML: errorHTML
            )
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
