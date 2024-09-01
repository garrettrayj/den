//
//  BrowserViewModel.swift
//  Den
//
//  Created by Garrett Johnson on 10/2/23.
//  Copyright © 2023 Garrett Johnson. All rights reserved.
//

import SwiftUI
import WebKit

@MainActor
final class BrowserViewModel: NSObject, ObservableObject {
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
    @Published var isReaderable = false
    @Published var showingReader = false
    @Published var mercuryObject: MercuryObject?
    @Published var useBlocklists = true
    @Published var browserRulesListsLoaded = false
    @Published var readerRulesListsLoaded = false
    @Published var useReaderAutomatically = false
    @Published var userTintHex: String?
    @Published var allowJavaScript = true
    @Published var browserZoom: PageZoomLevel = .oneHundredPercent
    @Published var readerZoom: PageZoomLevel = .oneHundredPercent
    
    var contentRuleLists: [WKContentRuleList]?

    func loadURL(url: URL?) {
        guard let url = url else { return }
        
        if useBlocklists && !browserRulesListsLoaded, let contentRuleLists = contentRuleLists {
            for ruleList in contentRuleLists {
                browserWebView?.configuration.userContentController.add(ruleList)
            }
            browserRulesListsLoaded = true
        } else if !useBlocklists && browserRulesListsLoaded {
            browserWebView?.configuration.userContentController.removeAllContentRuleLists()
            browserRulesListsLoaded = false
        }
        
        browserWebView?
            .configuration
            .defaultWebpagePreferences
            .allowsContentJavaScript = allowJavaScript

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
    
    func toggleBlocklists() async {
        useBlocklists.toggle()
        loadURL(url: url)
    }
    
    func toggleJavaScript() async {
        allowJavaScript.toggle()
        loadURL(url: url)
    }

    func showReader() {
        showingReader = true
    }

    func hideReader() {
        useReaderAutomatically = false
        showingReader = false
    }

    func toggleReader() {
        if showingReader {
            hideReader()
        } else {
            showReader()
        }
    }
    
    func setBrowserZoom(_ level: PageZoomLevel) {
        browserZoom = level
        browserWebView?.pageZoom = CGFloat(level.rawValue) / 100
    }

    func setReaderZoom(_ level: PageZoomLevel) {
        readerZoom = level
        #if os(macOS)
        readerWebView?.pageZoom = CGFloat(level.rawValue) / 100
        #else
        let script = """
        document.getElementsByTagName('body')[0].style.webkitTextSizeAdjust='\(level.rawValue)%'
        """
        readerWebView?.evaluateJavaScript(script, completionHandler: nil)
        #endif
    }

    func loadReader(initialZoom: PageZoomLevel) {
        var baseURL: URL?

        if
            let pageURL = url,
            var pageURLComponents = URLComponents(url: pageURL, resolvingAgainstBaseURL: false)
        {
            pageURLComponents.path = ""
            baseURL = pageURLComponents.url
        }
        
        if useBlocklists && !readerRulesListsLoaded, let contentRuleLists = contentRuleLists {
            for ruleList in contentRuleLists {
                readerWebView?.configuration.userContentController.add(ruleList)
            }
            readerRulesListsLoaded = true
        } else if !useBlocklists && readerRulesListsLoaded {
            readerWebView?.configuration.userContentController.removeAllContentRuleLists()
            readerRulesListsLoaded = false
        }

        readerWebView?.loadHTMLString(
            generateReaderHTML(initialZoom: initialZoom),
            baseURL: baseURL
        )
    }
    
    func clearReader() {
        readerWebView?.loadHTMLString("<html/>", baseURL: nil)
    }

    // swiftlint:disable function_body_length
    private func generateReaderHTML(initialZoom: PageZoomLevel) -> String {
        guard
            let title = mercuryObject?.title,
            let content = mercuryObject?.cleanedContent
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
        <body style="-webkit-text-size-adjust: \(initialZoom.rawValue)%;">
        <header id="den-header">
        <h1 id="den-title">\(title)</h1>
        """

        if
            let excerpt = mercuryObject?.excerpt,
            excerpt.prefix(20) != mercuryObject?.textContent?.prefix(20)
        {
            html += "<div id=\"den-excerpt\">\(excerpt)</div>"
        }
        
        if let byline = mercuryObject?.author {
            html += "<p id=\"den-author\">\(byline)</p>"
        }

        if let date = mercuryObject?.date_published {
            html += """
            <p id="den-dateline">
                \(date.formatted(date: .complete, time: .shortened))
                <span id="den-dateline-relative">
                (\(date.formatted(.relative(presentation: .numeric))))
                </span>
            </p>
            """
        }

        if
            let leadImageURL = mercuryObject?.lead_image_url,
            !content.prefix(content.count / 4).contains("<img") && !content.contains(leadImageURL)
        {
            html += "<img src=\"\(leadImageURL)\" />"
        }

        html += """
        </header>
        \(content)
        """
        
        if content.contains("twitter-tweet") {
            html += """
            <script async src="https://platform.twitter.com/widgets.js" charset="utf-8"></script>
            """
        }
        
        if content.contains("instagram-media") {
            html += """
            <script async src="//www.instagram.com/embed.js"></script>
            """
        }
        
        if content.contains("tiktok-embed") {
            html += """
            <script async src="https://www.tiktok.com/embed.js"></script>
            """
        }
        
        if content.contains("reddit-embed") {
            html += """
            <script async src="https://embed.reddit.com/widgets.js"></script>
            """
        }
        
        if content.contains("lazyload") {
            html += """
            <script async src="http://afarkas.github.io/lazysizes/lazysizes.min.js"></script>
            """
        }
        
        html += """
        </body>
        </html>
        """
        
        return html
    }
    // swiftlint:enable function_body_length

    private var readerStyles: String {
        guard
            let path = Bundle.main.path(forResource: "Reader", ofType: "css"),
            let styles = try? String(contentsOfFile: path, encoding: .utf8)
        else {
            return ""
        }

        return styles.replacingOccurrences(
            of: "$TINT_COLOR",
            with: userTintHex ?? "accentcolor"
        )
    }
}
