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
                if scenePhase == .active && !downloadManager.browserDownloads.isEmpty {
                    ToolbarItem(placement: .bottomBar) {
                        Spacer()
                    }
                    ToolbarItem(placement: .bottomBar) {
                        // Scene phase check is required because downloadManager environment object
                        // is not available when app moves to background.
                        DownloadsButton()
                    }
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
