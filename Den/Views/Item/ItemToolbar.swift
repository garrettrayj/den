//
//  ItemToolbar.swift
//  Den
//
//  Created by Garrett Johnson on 12/22/23.
//  Copyright © 2023 Garrett Johnson
//

import SwiftUI

struct ItemToolbar: ToolbarContent {
    #if os(iOS)
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    #endif

    @ObservedObject var item: Item
    @ObservedObject var browserViewModel: BrowserViewModel

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
            TagsMenu(item: item)
        }
        ToolbarItem {
            if let url = browserViewModel.url {
                ShareButton(url: url)
            }
        }
        #else
        if horizontalSizeClass == .compact {
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
                    if let url = browserViewModel.url {
                        ShareButton(url: url)
                    }
                }
                ToolbarItem(placement: .bottomBar) {
                    Spacer()
                }
                ToolbarItem(placement: .bottomBar) {
                    TagsMenu(item: item)
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
                TagsMenu(item: item)
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
                if let url = browserViewModel.url {
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
