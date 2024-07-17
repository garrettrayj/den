//
//  BrowserView.swift
//  Den
//
//  Created by Garrett Johnson on 10/3/23.
//  Copyright © 2023 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI
import WebKit

struct BrowserView: View {
    @Environment(\.self) private var environment
    
    @EnvironmentObject private var dataController: DataController
    
    var url: URL
    var useBlocklists: Bool?
    var useReaderAutomatically: Bool?
    var allowJavaScript: Bool?

    @ObservedObject var browserViewModel: BrowserViewModel

    @AppStorage("AccentColor") private var accentColor: AccentColor?
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
                    browserViewModel.contentRuleLists = await BlocklistManager.getContentRuleLists(
                        container: dataController.container
                    )
                    browserViewModel.useBlocklists = useBlocklists ?? true
                    browserViewModel.useReaderAutomatically = useReaderAutomatically ?? false
                    browserViewModel.allowJavaScript = allowJavaScript ?? true
                    browserViewModel.userTintHex = accentColor?.color.hexString(environment: environment)
                    browserViewModel.setBrowserZoom(browserZoom)
                    
                    browserViewModel.loadURL(url: url)
                }
                .onDisappear {
                    // Fix for videos continuing to play after view is dismissed
                    browserViewModel.loadBlank()
                }
                .frame(height: browserViewModel.showingReader ? 0 : nil)
                .opacity(browserViewModel.showingReader ? 0 : 1)
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
        .toolbarBackground(.visible, for: .bottomBar)
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
            // Buttons in background to fix keyboard shortcuts
            ToggleReaderButton(browserViewModel: browserViewModel)
            
            if browserViewModel.showingReader {
                ReaderZoom(browserViewModel: browserViewModel)
            } else {
                BrowserZoom(browserViewModel: browserViewModel)
            }
        }
    }
}
