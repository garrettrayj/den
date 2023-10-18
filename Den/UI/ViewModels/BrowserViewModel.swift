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

class BrowserViewModel: NSObject, ObservableObject {
    weak var browserWebView: WKWebView? {
        didSet {
            Task {
                await MainActor.run {
                    browserWebView?.publisher(for: \.canGoBack).assign(to: &$canGoBack)
                    browserWebView?.publisher(for: \.canGoForward).assign(to: &$canGoForward)
                    browserWebView?.publisher(for: \.estimatedProgress).assign(to: &$estimatedProgress)
                    browserWebView?.publisher(for: \.url).assign(to: &$url)
                    browserWebView?.publisher(for: \.isLoading).assign(to: &$isLoading)
                }
            }
        }
    }

    weak var readerWebView: WKWebView?

    @Published var url: URL?
    @Published var estimatedProgress: Double = 0
    @Published var canGoBack = false
    @Published var canGoForward = false
    @Published var isLoading = true
    @Published var browserError: Error?
    @Published var isReaderable = false
    @Published var showingReader = false
    @Published var mercuryObject: MercuryObject?
    @Published var useReaderAutomatically = false
    @Published var userTintHex: String?

    func loadURL(url: URL?) {
        guard let url = url else { return }
        browserWebView?.load(URLRequest(url: url))
    }

    func loadBlank() {
        browserWebView?.loadHTMLString("<html/>", baseURL: nil)
    }

    func goBack() {
        browserWebView?.goBack()
    }

    func goForward() {
        browserWebView?.goForward()
    }

    func stop() {
        browserWebView?.stopLoading()
    }

    func reload() {
        showingReader = false
        browserWebView?.reload()
    }

    func showReader() {
        withAnimation {
            showingReader = true
        }
    }

    func hideReader() {
        withAnimation {
            useReaderAutomatically = false
            showingReader = false
        }
    }

    func toggleReader() {
        if showingReader {
            hideReader()
        } else {
            showReader()
        }
    }

    func setBrowserZoom(_ level: PageZoomLevel) {
        browserWebView?.pageZoom = CGFloat(level.rawValue) / 100
    }

    func setReaderZoom(_ level: PageZoomLevel) {
        readerWebView?.pageZoom = CGFloat(level.rawValue) / 100
    }

    func loadReader() {
        var baseURL: URL?

        if
            let pageURL = url,
            var pageURLComponents = URLComponents(url: pageURL, resolvingAgainstBaseURL: false)
        {
            pageURLComponents.path = ""
            baseURL = pageURLComponents.url
        }

        readerWebView?.loadHTMLString(readerHTML, baseURL: baseURL)
    }

    private var readerHTML: String {
        guard
            let title = mercuryObject?.title,
            let content = mercuryObject?.content
        else {
            return """
            <html>
            <head>
            <title>Reader Unavailable</title>
            </head>
            <body>
            <h1>Reader Unavailable</h1>
            </body>
            </html>
            """
        }

        var html = """
            <html>
            <head>
            <title>Den Reader</title>
            <meta name="viewport" content="width=device-width, initial-scale=1.0, shrink-to-fit=no, user-scalable=no" />
            <style>\(readerStyles)</style>
            </head>
            <body>
            <header>
            <h1 id="den-title">\(title)</h1>
        """

        if let byline = mercuryObject?.author {
            html += "<p id=\"den-author\">\(byline)</p>"
        }

        if let date = mercuryObject?.date_published {
            html += """
            <p id="den-date-published">
                \(date.formatted(date: .complete, time: .shortened))
                (\(date.formatted(.relative(presentation: .numeric))))
            </p>
            """
        }

        if
            let leadImageURL = mercuryObject?.lead_image_url,
            !content.prefix(1000).contains("<img") && !content.prefix(1000).contains("<picture")
        {
            html += "<img src=\"\(leadImageURL.absoluteString)\" />"
        }

        html += """
            </header>
            <main>
            \(content)
            </body>
            </html>
        """
        
        return html
    }

    private var readerStyles: String {
        guard
            let path = Bundle.main.path(forResource: "Reader", ofType: "css"),
            var styles = try? String(contentsOfFile: path)
        else {
            return ""
        }

        #if os(macOS)
        if
            let path = Bundle.main.path(forResource: "ReaderMac", ofType: "css"),
            let macStyles = try? String(contentsOfFile: path).components(separatedBy: .newlines).joined()
        {
            styles += macStyles
        }
        #endif

        return styles.replacingOccurrences(
            of: "$TINT_COLOR",
            with: userTintHex ?? "accentcolor"
        )
    }
}
