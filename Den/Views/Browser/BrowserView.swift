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
    var readerMode: Bool?
    var extraToolbar: ExtraToolbar?

    @StateObject var browserViewModel = BrowserViewModel()

    init(
        url: URL,
        readerMode: Bool? = nil,
        @ToolbarContentBuilder extraToolbar: @escaping () -> ExtraToolbar?
    ) {
        self.url = url
        self.readerMode = readerMode
        self.extraToolbar = extraToolbar()
    }

    var body: some View {
        #if os(macOS)
        BrowserWebView(viewModel: browserViewModel)
            .onAppear {
                browserViewModel.url = url
                browserViewModel.loadURL()
            }
            .navigationBarBackButtonHidden()
            .navigationTitle(browserViewModel.url?.host() ?? "")
            .ignoresSafeArea()
            .overlay(alignment: .top) {
                if browserViewModel.isLoading {
                    ProgressView(value: browserViewModel.estimatedProgress, total: 1)
                        .progressViewStyle(ThinLinearProgressViewStyle())
                }
            }
            .toolbar {
                BrowserToolbar(browserViewModel: browserViewModel)
                extraToolbar
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
        readerMode: Bool? = nil
    ) {
        self.url = url
        self.readerMode = readerMode
    }
}
