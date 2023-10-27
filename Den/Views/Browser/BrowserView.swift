//
//  BrowserView.swift
//  Den
//
//  Created by Garrett Johnson on 10/3/23.
//  Copyright © 2023 Garrett Johnson
//

import SwiftUI

struct BrowserView<ExtraToolbar: ToolbarContent>: View {
    @Environment(\.self) private var environment
    @Environment(\.userTint) private var userTint

    var url: URL
    var useBlocklists: Bool?
    var useReaderAutomatically: Bool?
    var allowJavaScript: Bool?
    var extraToolbar: ExtraToolbar?

    @StateObject var browserViewModel = BrowserViewModel()

    @AppStorage("BrowserZoom") var browserZoom: PageZoomLevel = .oneHundredPercent
    @AppStorage("ReaderZoom") var readerZoom: PageZoomLevel = .oneHundredPercent
    
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
        BrowserWebView(browserViewModel: browserViewModel)
            .task {
                browserViewModel.blocklists = Array(blocklists)
                browserViewModel.useBlocklists = useBlocklists ?? true
                browserViewModel.useReaderAutomatically = useReaderAutomatically ?? false
                browserViewModel.allowJavaScript = allowJavaScript ?? true
                browserViewModel.userTintHex = userTint?.hexString(environment: environment)
                browserViewModel.setBrowserZoom(browserZoom)
                await browserViewModel.loadURL(url: url)
            }
            .onDisappear {
                // Fix for videos continuing to play after view is dismissed
                browserViewModel.loadBlank()
            }
            #if os(macOS)
            .padding(.top, 1)
            #endif
            .ignoresSafeArea()
            .navigationBarBackButtonHidden()
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
            .overlay(alignment: .top) {
                if browserViewModel.showingReader == true {
                    ReaderWebView(browserViewModel: browserViewModel)
                        .ignoresSafeArea()
                        .onAppear {
                            browserViewModel.setReaderZoom(readerZoom)
                            browserViewModel.loadReader(initialZoom: readerZoom)
                        }
                        .onChange(of: browserViewModel.mercuryObject) {
                            browserViewModel.loadReader(initialZoom: readerZoom)
                        }
                        #if os(macOS)
                        .transition(.flipFromBottom)
                        #else
                        .transition(.flipFromTop)
                        #endif        
                }
                
                if browserViewModel.isLoading {
                    ProgressView(value: browserViewModel.estimatedProgress, total: 1)
                        .progressViewStyle(ThinLinearProgressViewStyle())
                        .ignoresSafeArea(edges: .horizontal)
                }
            }
        
        /*
        GeometryReader { geometry in
            
            
            ZStack(alignment: .top) {
                
                    
                

                if browserViewModel.isLoading {
                    ProgressView(value: browserViewModel.estimatedProgress, total: 1)
                        .progressViewStyle(ThinLinearProgressViewStyle())
                        .ignoresSafeArea(edges: .horizontal)
                }
            }
            .background {
                // Buttons in background to fix keyboard shortcuts
                ToggleReaderButton(browserViewModel: browserViewModel)
                ZoomControlGroup(zoomLevel: browserViewModel.showingReader ? $readerZoom : $browserZoom)
            }
            .navigationBarBackButtonHidden()
            .navigationTitle(browserViewModel.url?.host() ?? "")
            .toolbar {
                BrowserToolbar(
                    browserViewModel: browserViewModel,
                    browserZoom: $browserZoom,
                    readerZoom: $readerZoom
                )
                extraToolbar
            }
            .onChange(of: browserZoom) {
                browserViewModel.setBrowserZoom(browserZoom)
            }
            .onChange(of: readerZoom) {
                browserViewModel.setReaderZoom(readerZoom)
            }
            #if os(iOS)
            .toolbarBackground(.visible)
            #endif
             
        }
         */
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
