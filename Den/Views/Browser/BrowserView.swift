//
//  BrowserView.swift
//  Den
//
//  Created by Garrett Johnson on 10/3/23.
//  Copyright © 2023 Garrett Johnson. All rights reserved.
//

import SwiftUI
import WebKit

struct BrowserView: View {
    @Environment(\.accentHexString) private var accentHexString
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    var url: URL
    var useBlocklists: Bool?
    var useReaderAutomatically: Bool?
    var allowJavaScript: Bool?

    @ObservedObject var browserViewModel: BrowserViewModel

    @AppStorage("BrowserZoom") private var browserZoom: PageZoomLevel = .oneHundredPercent
    @AppStorage("ReaderZoom") private var readerZoom: PageZoomLevel = .oneHundredPercent

    init(
        url: URL,
        useBlocklists: Bool? = nil,
        useReaderAutomatically: Bool? = nil,
        allowJavaScript: Bool? = nil,
        browserViewModel: BrowserViewModel
    ) {
        self.url = url
        self.useBlocklists = useBlocklists
        self.useReaderAutomatically = useReaderAutomatically
        self.allowJavaScript = allowJavaScript
        self.browserViewModel = browserViewModel
    }

    var body: some View {
        ZStack {
            BrowserWebView(browserViewModel: browserViewModel)
                .task {
                    browserViewModel.contentRuleLists = await BlocklistManager.getContentRuleLists()
                    browserViewModel.useBlocklists = useBlocklists ?? true
                    browserViewModel.useReaderAutomatically = useReaderAutomatically ?? false
                    browserViewModel.allowJavaScript = allowJavaScript ?? true
                    browserViewModel.userTintHex = accentHexString
                    browserViewModel.setBrowserZoom(browserZoom)
                    
                    browserViewModel.loadURL(url: url)
                }
                .onDisappear {
                    // Fix for videos continuing to play after view is dismissed
                    browserViewModel.loadBlank()
                }
                .frame(height: browserViewModel.showingReader ? 0 : nil)
                .ignoresSafeArea()
            
            if browserViewModel.showingReader == true {
                ReaderWebView(browserViewModel: browserViewModel)
                    .task {
                        browserViewModel.setReaderZoom(readerZoom)
                        browserViewModel.loadReader(initialZoom: readerZoom)
                    }
                    .onChange(of: browserViewModel.mercuryObject) {
                        browserViewModel.loadReader(initialZoom: readerZoom)
                    }
                    .onDisappear {
                        // Fix for videos continuing to play after view is dismissed
                        browserViewModel.clearReader()
                    }
                    .ignoresSafeArea()
            }
            
            if browserViewModel.isLoading {
                ProgressView(value: browserViewModel.estimatedProgress, total: 1)
                    .progressViewStyle(ThinLinearProgressViewStyle())
                    .ignoresSafeArea(edges: .horizontal)
            }
        }
        .navigationTitle(browserViewModel.url?.host() ?? "")
        .toolbarBackground(.visible)
        #if os(iOS)
        .toolbarBackground(horizontalSizeClass == .compact ? .visible : .hidden, for: .bottomBar)
        #endif
        .onChange(of: browserViewModel.browserZoom) {
            browserZoom = browserViewModel.browserZoom
            browserViewModel.setBrowserZoom(browserViewModel.browserZoom)
        }
        .onChange(of: browserViewModel.readerZoom) {
            readerZoom = browserViewModel.readerZoom
            browserViewModel.setReaderZoom(browserViewModel.readerZoom)
        }
        .background(alignment: .bottom) {
            Group {
                // Buttons in background to fix keyboard shortcuts
                ToggleReaderButton(browserViewModel: browserViewModel)
                
                if browserViewModel.showingReader {
                    ReaderZoom(browserViewModel: browserViewModel)
                } else {
                    BrowserZoom(browserViewModel: browserViewModel)
                }
            }
            .offset(y: 100)
        }
    }
}
