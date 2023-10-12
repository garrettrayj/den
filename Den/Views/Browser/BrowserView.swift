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
    var url: URL
    var useReaderAutomatically: Bool?
    var readerPublishedDate: Date?
    var readerByline: String?
    var extraToolbar: ExtraToolbar?

    @StateObject var browserViewModel = BrowserViewModel()

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
            BrowserWebView(viewModel: browserViewModel)
                .onAppear {
                    browserViewModel.useReaderAutomatically = useReaderAutomatically ?? false
                    browserViewModel.loadURL(url: url)
                }
                .onDisappear {
                    // Fix for videos continuing to play after view is dismissed
                    browserViewModel.loadBlank()
                }
                .navigationBarBackButtonHidden()
                .navigationTitle(browserViewModel.url?.host() ?? "")
                .toolbar {
                    BrowserToolbar(browserViewModel: browserViewModel)
                    extraToolbar
                }
                .padding(.top, 1)
                .ignoresSafeArea()
                .overlay(alignment: .top) {
                    if browserViewModel.isLoading {
                        ProgressView(value: browserViewModel.estimatedProgress, total: 1)
                            .progressViewStyle(ThinLinearProgressViewStyle())
                    }
                }

            if browserViewModel.showingReader == true {
                ReaderWebView(
                    browserViewModel: browserViewModel,
                    publishedDate: readerPublishedDate,
                    byline: readerByline
                )
                .transition(.flipFromBottom)
                .ignoresSafeArea()
            }
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
