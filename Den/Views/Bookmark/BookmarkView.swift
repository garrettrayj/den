//
//  BookmarkView.swift
//  Den
//
//  Created by Garrett Johnson on 9/13/23.
//  Copyright © 2023 Garrett Johnson. All rights reserved.
//

import SwiftUI

struct BookmarkView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(\.scenePhase) private var scenePhase
    
    @EnvironmentObject private var downloadManager: DownloadManager
    
    @ObservedObject var bookmark: Bookmark
    
    @StateObject private var browserViewModel = BrowserViewModel()

    var body: some View {
        if
            let url = bookmark.link,
            !bookmark.isDeleted && bookmark.managedObjectContext != nil 
        {
            BrowserView(
                url: url,
                useBlocklists: bookmark.feed?.useBlocklists,
                useReaderAutomatically: bookmark.feed?.readerMode,
                browserViewModel: browserViewModel
            )
            .toolbar { toolbarContent }
        } else {
            ContentUnavailable {
                Label {
                    Text("Untagged", comment: "Object removed message.")
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
                    UnbookmarkButton(bookmark: bookmark) {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .bottomBar) {
                    Spacer()
                }
                ToolbarItem(placement: .bottomBar) {
                    SystemBrowserButton(url: url)
                }
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
