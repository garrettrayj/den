//
//  BrowserToolbar.swift
//  Den
//
//  Created by Garrett Johnson on 6/14/23.
//  Copyright © 2023 Garrett Johnson
//

import SwiftUI

struct BrowserToolbar: ToolbarContent {
    #if os(iOS)
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    #endif

    @ObservedObject var browserViewModel: BrowserViewModel

    @Binding var browserZoom: PageZoomLevel
    @Binding var readerZoom: PageZoomLevel

    var body: some ToolbarContent {
        #if os(macOS)
        ToolbarItem(placement: .navigation) {
            DoneButton()
        }
        ToolbarItem(placement: .navigation) {
            GoBackButton(browserViewModel: browserViewModel)
        }
        ToolbarItem(placement: .navigation) {
            GoForwardButton(browserViewModel: browserViewModel)
        }
        ToolbarItem(placement: .navigation) {
            formatMenu
        }
        ToolbarItem {
            StopReloadButton(browserViewModel: browserViewModel)
        }
        ToolbarItem {
            if let url = browserViewModel.url {
                ShareButton(url: url)
            }
        }
        ToolbarItem {
            if let url = browserViewModel.url {
                Link(destination: url) {
                    OpenInBrowserLabel()
                }
                .buttonStyle(.bordered)
            }
        }
        #else
        if horizontalSizeClass == .compact {
            ToolbarItem {
                formatMenu
            }
            ToolbarItem {
                StopReloadButton(browserViewModel: browserViewModel)
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
                    if let url = browserViewModel.url {
                        ShareButton(url: url)
                    }
                }
                ToolbarItem(placement: .bottomBar) {
                    Spacer()
                }
                ToolbarItem(placement: .bottomBar) {
                    if let url = browserViewModel.url {
                        Link(destination: url) {
                            OpenInBrowserLabel()
                        }
                    }
                }
                ToolbarItem(placement: .bottomBar) {
                    Spacer()
                }
            }
        } else {
            ToolbarItem(placement: .topBarLeading) {
                formatMenu
            }
            ToolbarItem(placement: .topBarLeading) {
                StopReloadButton(browserViewModel: browserViewModel)
            }
            ToolbarItem {
                GoBackButton(browserViewModel: browserViewModel)
            }
            ToolbarItem {
                GoForwardButton(browserViewModel: browserViewModel)
            }
            ToolbarItem {
                if let url = browserViewModel.url {
                    ShareButton(url: url)
                }
            }
            ToolbarItem {
                if let url = browserViewModel.url {
                    Link(destination: url) {
                        OpenInBrowserLabel()
                    }
                }
            }
        }
        #endif
    }
    
    @ViewBuilder
    private var formatMenu: some View {
        if browserViewModel.showingReader {
            ReaderFormatMenu(browserViewModel: browserViewModel, readerZoom: $readerZoom)
        } else {
            BrowserFormatMenu(browserViewModel: browserViewModel, browserZoom: $browserZoom)
        }
    }
}
