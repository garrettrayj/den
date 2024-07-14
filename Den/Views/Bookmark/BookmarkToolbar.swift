//
//  BookmarkToolbar.swift
//  Den
//
//  Created by Garrett Johnson on 12/22/23.
//  Copyright © 2023 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

struct BookmarkToolbar: ToolbarContent {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(\.scenePhase) private var scenePhase
    
    @EnvironmentObject private var downloadManager: DownloadManager

    @ObservedObject var bookmark: Bookmark
    @ObservedObject var browserViewModel: BrowserViewModel

    var body: some ToolbarContent {
        #if os(macOS)
        if !downloadManager.browserDownloads.isEmpty {
            ToolbarItem {
                DownloadsButton()
            }
        }
        ToolbarItem {
            formatMenu
        }
        ToolbarItem {
            GoBackButton(browserViewModel: browserViewModel)
        }
        ToolbarItem {
            GoForwardButton(browserViewModel: browserViewModel)
        }
        ToolbarItem {
            StopReloadButton(browserViewModel: browserViewModel)
        }
        ToolbarItem {
            UnbookmarkButton(bookmark: bookmark) {
                dismiss()
            }
        }
        if let url = browserViewModel.url {
            ToolbarItem {
                SystemBrowserButton(url: url)
            }
            ToolbarItem {
                ShareButton(item: url).help(Text("Share", comment: "Button help text."))
            }
        }
        #else
        if horizontalSizeClass == .compact {
            ToolbarItem {
                UnbookmarkButton(bookmark: bookmark) {
                    dismiss()
                }
            }
            ToolbarItem {
                formatMenu
            }
            ToolbarItem(placement: .bottomBar) {
                GoBackButton(browserViewModel: browserViewModel)
            }
            ToolbarItem(placement: .bottomBar) {
                Spacer()
            }
            ToolbarItem(placement: .bottomBar) {
                GoForwardButton(browserViewModel: browserViewModel)
            }
            ToolbarItem(placement: .bottomBar) {
                Spacer()
            }
            if let url = browserViewModel.url {
                ToolbarItem(placement: .bottomBar) {
                    ShareButton(item: url)
                }
                ToolbarItem(placement: .bottomBar) {
                    Spacer()
                }
                ToolbarItem(placement: .bottomBar) {
                    SystemBrowserButton(url: url)
                }
                ToolbarItem(placement: .bottomBar) {
                    Spacer()
                }
            }
            ToolbarItem(placement: .bottomBar) {
                StopReloadButton(browserViewModel: browserViewModel)
            }
            // Scene phase check is required because downloadManager environment object
            // is not available when app moves to background.
            if scenePhase == .active && !downloadManager.browserDownloads.isEmpty {
                ToolbarItem(placement: .bottomBar) {
                    Spacer()
                }
                ToolbarItem(placement: .bottomBar) {
                    DownloadsButton()
                }
            }
        } else {
            ToolbarItem(placement: .topBarLeading) {
                UnbookmarkButton(bookmark: bookmark) {
                    dismiss()
                }
            }
            ToolbarItem(placement: .topBarLeading) {
                formatMenu
            }
            if scenePhase == .active && !downloadManager.browserDownloads.isEmpty {
                ToolbarItem {
                    // Scene phase check is required because downloadManager environment object
                    // is not available when app moves to background.
                    DownloadsButton()
                }
            }
            ToolbarItem {
                GoBackButton(browserViewModel: browserViewModel)
            }
            ToolbarItem {
                GoForwardButton(browserViewModel: browserViewModel)
            }
            ToolbarItem {
                StopReloadButton(browserViewModel: browserViewModel)
            }
            if let url = browserViewModel.url {
                ToolbarItem {
                    SystemBrowserButton(url: url)
                }
                ToolbarItem {
                    ShareButton(item: url)
                }
            }
        }
        #endif
    }
    
    @ViewBuilder
    private var formatMenu: some View {
        if browserViewModel.showingReader {
            ReaderFormatMenu(browserViewModel: browserViewModel)
        } else {
            BrowserFormatMenu(browserViewModel: browserViewModel)
        }
    }
}
