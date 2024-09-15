//
//  ItemView.swift
//  Den
//
//  Created by Garrett Johnson on 7/8/22.
//  Copyright © 2022 Garrett Johnson. All rights reserved.
//

import SwiftUI

struct ItemView: View {
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.scenePhase) private var scenePhase

    @EnvironmentObject private var downloadManager: DownloadManager

    @ObservedObject var item: Item
    
    @StateObject private var browserViewModel = BrowserViewModel()

    var body: some View {
        if let url = item.link, item.managedObjectContext != nil && item.feedData?.feed != nil {
            BrowserView(
                url: url,
                useBlocklists: item.feedData?.feed?.useBlocklists,
                useReaderAutomatically: item.feedData?.feed?.readerMode,
                allowJavaScript: item.feedData?.feed?.allowJavaScript,
                browserViewModel: browserViewModel
            )
            .toolbar { toolbarContent }
            .onAppear {
                HistoryUtility.markItemRead(context: viewContext, item: item)
            }
        } else {
            ContentUnavailable {
                Label {
                    Text("Item Removed", comment: "Object removed message.")
                } icon: {
                    Image(systemName: "trash")
                }
            }
        }
    }
    
    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
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
            BrowserNavControlGroup(browserViewModel: browserViewModel)
        }
        ToolbarItem {
            StopReloadButton(browserViewModel: browserViewModel)
        }
        ToolbarItem {
            ToggleBookmarkedButton(item: item)
        }
        if let url = browserViewModel.url {
            ToolbarItem {
                ShareButton(item: url)
            }
            ToolbarItem {
                SystemBrowserButton(url: url)
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
                    ToggleBookmarkedButton(item: item)
                }
                ToolbarItem(placement: .bottomBar) {
                    Spacer()
                }
                ToolbarItem(placement: .bottomBar) {
                    SystemBrowserButton(url: url)
                }
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
                Spacer()
            }
            ToolbarItem(placement: .topBarLeading) {
                ToggleBookmarkedButton(item: item)
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
                    ShareButton(item: url)
                }
                ToolbarItem {
                    SystemBrowserButton(url: url)
                }
            }
        }
        #endif
    }

    @ViewBuilder
    private var formatMenu: some View {
        if browserViewModel.showingReader {
            ReaderViewMenu(browserViewModel: browserViewModel)
        } else {
            BrowserViewMenu(browserViewModel: browserViewModel)
        }
    }
}
