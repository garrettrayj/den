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

struct BrowserView<ExtraToolbar: ToolbarContent>: View {
    @Environment(\.self) private var environment
    @Environment(\.userTint) private var userTint

    var url: URL
    var useReaderAutomatically: Bool?
    var readerPublishedDate: Date?
    var readerByline: String?
    var extraToolbar: ExtraToolbar?

    @StateObject var browserViewModel = BrowserViewModel()

    @AppStorage("BrowserZoom") var browserZoom: PageZoomLevel = .oneHundredPercent
    @AppStorage("ReaderZoom") var readerZoom: PageZoomLevel = .oneHundredPercent

    init(
        url: URL,
        useReaderAutomatically: Bool? = nil,
        readerPublishedDate: Date? = nil,
        readerByline: String? = nil,
        @ToolbarContentBuilder extraToolbar: @escaping () -> ExtraToolbar?
    ) {
        self.url = url
        self.useReaderAutomatically = useReaderAutomatically
        self.readerPublishedDate = readerPublishedDate
        self.readerByline = readerByline
        self.extraToolbar = extraToolbar()
    }

    var body: some View {
        #if os(macOS)
        ZStack(alignment: .top) {
            BrowserWebView(browserViewModel: browserViewModel)
                .onAppear {
                    browserViewModel.useReaderAutomatically = useReaderAutomatically ?? false
                    browserViewModel.userTintHex = userTint?.hexString(environment: environment)
                    browserViewModel.setBrowserZoom(browserZoom)
                    browserViewModel.loadURL(url: url)
                }
                .onDisappear {
                    // Fix for videos continuing to play after view is dismissed
                    browserViewModel.loadBlank()
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
                .padding(.top, 1)
                .ignoresSafeArea()

            if browserViewModel.showingReader == true {
                ReaderWebView(browserViewModel: browserViewModel)
                    .transition(.move(edge: .bottom))
                    .ignoresSafeArea()
                    .onAppear {
                        browserViewModel.setReaderZoom(readerZoom)
                        browserViewModel.loadReader()
                    }
                    .onChange(of: browserViewModel.mercuryObject) {
                        browserViewModel.loadReader()
                    }
            }

            if browserViewModel.isLoading {
                ProgressView(value: browserViewModel.estimatedProgress, total: 1)
                    .progressViewStyle(ThinLinearProgressViewStyle())
            }
        }
        .background {
            // Controls in background for keyboard shortcuts
            ToggleReaderButton(browserViewModel: browserViewModel)
            ZoomControlGroup(
                zoomLevel: browserViewModel.showingReader ? $readerZoom : $browserZoom
            )
        }
        .onChange(of: browserZoom) {
            browserViewModel.setBrowserZoom(browserZoom)
        }
        .onChange(of: readerZoom) {
            browserViewModel.setReaderZoom(readerZoom)
        }
        #else
        SafariView(url: url, readerMode: readerMode)
            .toolbar(.hidden)
            .background(Color(.systemGroupedBackground), ignoresSafeAreaEdges: .all)
            .ignoresSafeArea()
        #endif
    }
}

extension BrowserView where ExtraToolbar == Never {
    init(
        url: URL,
        useReaderAutomatically: Bool? = nil,
        readerPublishedDate: Date? = nil,
        readerByline: String? = nil
    ) {
        self.url = url
        self.useReaderAutomatically = useReaderAutomatically
        self.readerPublishedDate = readerPublishedDate
        self.readerByline = readerByline
    }
}
