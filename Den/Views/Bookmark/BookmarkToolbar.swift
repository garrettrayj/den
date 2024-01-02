//
//  BookmarkToolbar.swift
//  Den
//
//  Created by Garrett Johnson on 12/22/23.
//  Copyright © 2023 Garrett Johnson
//

import SwiftUI

struct BookmarkToolbar: ToolbarContent {
    #if os(iOS)
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    #endif

    @ObservedObject var bookmark: Bookmark
    @ObservedObject var browserViewModel: BrowserViewModel

    var body: some ToolbarContent {
        #if os(macOS)
        ToolbarItem(placement: .navigation) {
            DoneButton()
        }
        ToolbarItem(placement: .navigation) {
            UntagButton(bookmark: bookmark)
        }
        ToolbarItem(placement: .navigation) {
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
            if let url = browserViewModel.url {
                ShareButton(url: url)
            }
        }
        #else
        if horizontalSizeClass == .compact {
            ToolbarItem {
                UntagButton(bookmark: bookmark)
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
                if let url = browserViewModel.url {
                    ToolbarItem(placement: .bottomBar) {
                        Spacer()
                    }
                    ToolbarItem(placement: .bottomBar) {
                        ShareButton(url: url)
                    }
                    ToolbarItem(placement: .bottomBar) {
                        Spacer()
                    }
                    ToolbarItem(placement: .bottomBar) {
                        SystemBrowserButton(url: url)
                    }
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
                UntagButton(bookmark: bookmark)
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
            if let url = browserViewModel.url {
                ToolbarItem {
                    SystemBrowserButton(url: url)
                }
                ToolbarItem {
                    ShareButton(url: url)
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
