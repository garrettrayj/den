//
//  BrowserView.swift
//  Den
//
//  Created by Garrett Johnson on 10/3/23.
//  Copyright © 2023 Garrett Johnson
//

import SwiftUI

struct BrowserView<ExtraToolbar: ToolbarContent>: View {
    #if os(iOS)
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    #endif
    @Environment(\.userTintHex) private var userTintHex

    var url: URL
    var useBlocklists: Bool?
    var useReaderAutomatically: Bool?
    var allowJavaScript: Bool?
    var extraToolbar: ExtraToolbar?

    @StateObject private var browserViewModel = BrowserViewModel()

    @AppStorage("BrowserZoom") private var browserZoom: PageZoomLevel = .oneHundredPercent
    @AppStorage("ReaderZoom") private var readerZoom: PageZoomLevel = .oneHundredPercent
    
    @FetchRequest(sortDescriptors: [])
    private var blocklists: FetchedResults<Blocklist>

    init(
        url: URL,
        useBlocklists: Bool? = nil,
        useReaderAutomatically: Bool? = nil,
        allowJavaScript: Bool? = nil,
        readerPublishedDate: Date? = nil,
        readerByline: String? = nil,
        @ToolbarContentBuilder extraToolbar: @escaping () -> ExtraToolbar?
    ) {
        self.url = url
        self.useBlocklists = useBlocklists
        self.useReaderAutomatically = useReaderAutomatically
        self.allowJavaScript = allowJavaScript
        self.extraToolbar = extraToolbar()
    }

    var body: some View {
        ZStack {
            BrowserWebView(browserViewModel: browserViewModel)
                .task {
                    browserViewModel.blocklists = Array(blocklists)
                    browserViewModel.useBlocklists = useBlocklists ?? true
                    browserViewModel.useReaderAutomatically = useReaderAutomatically ?? false
                    browserViewModel.allowJavaScript = allowJavaScript ?? true
                    browserViewModel.userTintHex = userTintHex
                    browserViewModel.setBrowserZoom(browserZoom)
                    await browserViewModel.loadURL(url: url)
                }
                .onDisappear {
                    // Fix for videos continuing to play after view is dismissed
                    browserViewModel.loadBlank()
                }
                #if os(macOS)
                .padding(.top, 1)
                .ignoresSafeArea()
                .navigationBarBackButtonHidden()
                #else
                .navigationBarBackButtonHidden(horizontalSizeClass != .compact)
                #endif
            
            if browserViewModel.showingReader == true {
                ReaderWebView(browserViewModel: browserViewModel)
                    .task {
                        browserViewModel.setReaderZoom(readerZoom)
                        await browserViewModel.loadReader(initialZoom: readerZoom)
                    }
                    .onChange(of: browserViewModel.mercuryObject) {
                        Task {
                            await browserViewModel.loadReader(initialZoom: readerZoom)
                        }
                    }
                    .onDisappear {
                        // Fix for videos continuing to play after view is dismissed
                        browserViewModel.clearReader()
                    }
                    #if os(macOS)
                    .transition(.flipFromBottom)
                    .ignoresSafeArea()
                    #else
                    .transition(.flipFromTop)
                    .ignoresSafeArea(edges: .vertical)
                    #endif
            }
            
            if browserViewModel.isLoading {
                ProgressView(value: browserViewModel.estimatedProgress, total: 1)
                    .progressViewStyle(ThinLinearProgressViewStyle())
                    .ignoresSafeArea(edges: .horizontal)
            }
            
            if let error = browserViewModel.browserError {
                ContentUnavailable {
                    Label {
                        Text("Error")
                    } icon: {
                        Image(systemName: "exclamationmark.octagon")
                    }
                } description: {
                    Text(error.localizedDescription)
                }
            }
        }
        .navigationTitle(browserViewModel.url?.host() ?? "")
        .toolbar {
            BrowserToolbar(
                browserViewModel: browserViewModel,
                browserZoom: $browserZoom,
                readerZoom: $readerZoom
            )
            extraToolbar
        }
        .toolbarBackground(.visible)
        .onChange(of: browserZoom) {
            browserViewModel.setBrowserZoom(browserZoom)
        }
        .onChange(of: readerZoom) {
            browserViewModel.setReaderZoom(readerZoom)
        }
        #if os(macOS)
        .background(alignment: .bottom) {
            // Buttons in background to fix keyboard shortcuts
            ToggleReaderButton(browserViewModel: browserViewModel)
            ZoomControlGroup(zoomLevel: browserViewModel.showingReader ? $readerZoom : $browserZoom)
        }
        #endif
    }
}

extension BrowserView where ExtraToolbar == Never {
    init(
        url: URL,
        useBlocklists: Bool? = nil,
        useReaderAutomatically: Bool? = nil,
        allowJavaScript: Bool? = nil
    ) {
        self.url = url
        self.useBlocklists = useBlocklists
        self.useReaderAutomatically = useReaderAutomatically
        self.allowJavaScript = allowJavaScript
    }
}
