//
//  ItemToolbar.swift
//  Den
//
//  Created by Garrett Johnson on 12/22/23.
//  Copyright © 2023 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

struct ItemToolbar: ToolbarContent {
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(\.scenePhase) private var scenePhase
    
    @Environment(DownloadManager.self) private var downloadManager

    @Bindable var item: Item
    @Bindable var browserViewModel: BrowserViewModel

    var body: some ToolbarContent {
        #if os(macOS)
        if !downloadManager.browserDownloads.isEmpty {
            ToolbarItem {
                DownloadsButton()
            }
        }
        ToolbarItem {
            BrowserFormatMenu(browserViewModel: browserViewModel)
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
            ToggleBookmarkedButton(item: item)
        }
        if let url = browserViewModel.url {
            ToolbarItem {
                SystemBrowserButton(url: url)
            }
            ToolbarItem {
                ShareButton(item: url)
            }
        }
        #else
        if horizontalSizeClass == .compact {
            ToolbarItem {
                ToggleBookmarkedButton(item: item)
            }
            ToolbarItem {
                BrowserFormatMenu(browserViewModel: browserViewModel)
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
        } else {
            ToolbarItem(placement: .topBarLeading) {
                ToggleBookmarkedButton(item: item)
            }
            ToolbarItem(placement: .topBarLeading) {
                BrowserFormatMenu(browserViewModel: browserViewModel)
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
}
