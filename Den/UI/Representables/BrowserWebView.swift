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
    @ObservedObject var browserViewModel: BrowserViewModel
    
    func makeWebView(context: Context) -> WKWebView {
        let wkWebView = WKWebView()
        wkWebView.isInspectable = true
        wkWebView.navigationDelegate = context.coordinator
        wkWebView.configuration.mediaTypesRequiringUserActionForPlayback = .all
        wkWebView.configuration.userContentController.add(context.coordinator, name: "reader")
        
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

    class Coordinator: NSObject, WKNavigationDelegate, WKScriptMessageHandler {
        let browserViewModel: BrowserViewModel

        init(browserViewModel: BrowserViewModel) {
            self.browserViewModel = browserViewModel
        }

        func webView(
            _ webView: WKWebView,
            didFailProvisionalNavigation navigation: WKNavigation!,
            withError error: Error
        ) {
            browserViewModel.browserError = error
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

#if os(macOS)
extension BrowserWebView: NSViewRepresentable {
    func makeNSView(context: Context) -> WKWebView {
        makeWebView(context: context)
    }

    func updateNSView(_ nsView: WKWebView, context: Context) {
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(browserViewModel: browserViewModel)
    }
}
#else
extension BrowserWebView: UIViewRepresentable {
     func makeUIView(context: Context) -> WKWebView {
         makeWebView(context: context)
     }

     func updateUIView(_ uiView: WKWebView, context: Context) {
     }

    func makeCoordinator() -> Coordinator {
        Coordinator(browserViewModel: browserViewModel)
    }
}
#endif
