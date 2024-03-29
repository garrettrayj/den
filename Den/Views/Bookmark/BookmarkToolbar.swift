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
    #if os(iOS)
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    #endif
    
    @EnvironmentObject private var downloadManager: DownloadManager

    @ObservedObject var bookmark: Bookmark
    @ObservedObject var browserViewModel: BrowserViewModel

    var body: some ToolbarContent {
        #if os(macOS)
        if !downloadManager.downloads.isEmpty {
            ToolbarItem {
                DownloadsButton(downloadManager: downloadManager)
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
            SystemBrowserButton(url: $browserViewModel.url)
        }
        ToolbarItem {
            UntagButton(bookmark: bookmark) {
                dismiss()
            }
        }
        ToolbarItem {
            ShareButton(url: $browserViewModel.url)
        }
        #else
        if horizontalSizeClass == .compact {
            ToolbarItem {
                UntagButton(bookmark: bookmark) {
                    dismiss()
                }
            }
            ToolbarItem {
                formatMenu
            }
            Group {
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
                ToolbarItem(placement: .bottomBar) {
                    ShareButton(url: $browserViewModel.url)
                }
                ToolbarItem(placement: .bottomBar) {
                    Spacer()
                }
                ToolbarItem(placement: .bottomBar) {
                    SystemBrowserButton(url: $browserViewModel.url)
                }
                ToolbarItem(placement: .bottomBar) {
                    Spacer()
                }
                ToolbarItem(placement: .bottomBar) {
                    StopReloadButton(browserViewModel: browserViewModel)
                }
            }
        } else {
            ToolbarItem(placement: .topBarLeading) {
                Spacer()
            }
            ToolbarItem(placement: .topBarLeading) {
                UntagButton(bookmark: bookmark) {
                    dismiss()
                }
            }
            ToolbarItem(placement: .topBarLeading) {
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
                SystemBrowserButton(url: $browserViewModel.url)
            }
            ToolbarItem {
                ShareButton(url: $browserViewModel.url)
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
