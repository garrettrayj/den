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

struct BrowserWebView {
    @Environment(\.openURL) private var openURL
    
    @ObservedObject var browserViewModel: BrowserViewModel
    
    func makeWebView(context: Context) -> WKWebView {
        let wkWebView = WKWebView()
        wkWebView.isInspectable = true
        wkWebView.navigationDelegate = context.coordinator
        wkWebView.uiDelegate = context.coordinator
        wkWebView.configuration.mediaTypesRequiringUserActionForPlayback = .all
        wkWebView.configuration.userContentController.add(context.coordinator, name: "reader")
        #if os(iOS)
        wkWebView.scrollView.contentInsetAdjustmentBehavior = .never
        wkWebView.scrollView.clipsToBounds = false
        #endif

        addMercuryScript(wkWebView.configuration.userContentController)
        addParseForReaderScript(wkWebView.configuration.userContentController)

        browserViewModel.browserWebView = wkWebView

        return wkWebView
    }

    private func addMercuryScript(_ contentController: WKUserContentController) {
        guard
            let path = Bundle.main.path(forResource: "Mercury", ofType: "js"),
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

    private func addParseForReaderScript(_ contentController: WKUserContentController) {
        guard
            let path = Bundle.main.path(forResource: "ParseForReader", ofType: "js"),
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
}

class BrowserWebViewCoordinator: NSObject {
    let browserViewModel: BrowserViewModel
    let openURL: OpenURLAction

    init(browserViewModel: BrowserViewModel, openURL: OpenURLAction) {
        self.browserViewModel = browserViewModel
        self.openURL = openURL
    }
}

extension BrowserWebViewCoordinator: WKNavigationDelegate {
    func webView(
        _ webView: WKWebView,
        didFailProvisionalNavigation navigation: WKNavigation!,
        withError error: Error
    ) {
        var url = URL(string: "error://Error")!
        
        if let urlError = error as? URLError {
            if let failingURL = urlError.failingURL {
                url = failingURL
            }
        }
        
        let errorHTML = WebViewError(error: error).html
        
        webView.loadSimulatedRequest(
            URLRequest(url: url),
            responseHTML: errorHTML
        )
    }
    
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
        download.delegate = self
    }
        
    func webView(
        _ webView: WKWebView,
        navigationResponse: WKNavigationResponse,
        didBecome download: WKDownload
    ) {
        download.delegate = self
    }
}

extension BrowserWebViewCoordinator: WKDownloadDelegate {
    func download(
        _ download: WKDownload,
        decideDestinationUsing response: URLResponse,
        suggestedFilename: String,
        completionHandler: @escaping (URL?) -> Void
    ) {
        guard let destinationDirectoryURL = try? FileManager.default.url(
            for: .downloadsDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: true
        ) else { return }
        
        let url = destinationDirectoryURL.appending(path: suggestedFilename)

        completionHandler(url)
        
        NotificationCenter.default.post(
            name: .downloadStarted,
            object: download,
            userInfo: nil
        )
    }
    
    func downloadDidFinish(_ download: WKDownload) {
        NotificationCenter.default.post(
            name: .downloadFinished,
            object: download,
            userInfo: nil
        )
    }
    
    func download(_ download: WKDownload, didFailWithError error: any Error, resumeData: Data?) {
        NotificationCenter.default.post(
            name: .downloadFailed,
            object: download,
            userInfo: ["error": error]
        )
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

        let jsonData = Data(jsonString.utf8)
        let decoder = JSONDecoder()

        let standardFormatter = ISO8601DateFormatter()
        standardFormatter.formatOptions = [.withInternetDateTime]
        
        let fractionalSecondsFormatter = ISO8601DateFormatter()
        standardFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]

        decoder.dateDecodingStrategy = .custom({ decoder in
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

    func makeCoordinator() -> BrowserWebViewCoordinator {
        BrowserWebViewCoordinator(browserViewModel: browserViewModel, openURL: openURL)
    }
}
#else
extension BrowserWebView: UIViewRepresentable {
     func makeUIView(context: Context) -> WKWebView {
         makeWebView(context: context)
     }

     func updateUIView(_ uiView: WKWebView, context: Context) {
     }

    func makeCoordinator() -> BrowserWebViewCoordinator {
        BrowserWebViewCoordinator(browserViewModel: browserViewModel, openURL: openURL)
    }
}
#endif
