//
//  DownloadsPopover.swift
//  Den
//
//  Created by Garrett Johnson on 4/1/24.
//  Copyright © 2024 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

struct DownloadsPopover: View {
    @EnvironmentObject private var downloadManager: DownloadManager
    
    @State private var selection = Set<BrowserDownload>()
    
    var body: some View {
        NavigationStack {
            List(selection: $selection) {
                ForEach(downloadManager.browserDownloads) { browserDownload in
                    DownloadStatus(browserDownload: browserDownload)
                        .tag(browserDownload)
                        .listRowInsets(.init(top: 8, leading: 8, bottom: 8, trailing: 8))
                }
            }
            .listStyle(.inset)
            .clipped()
            .background(Rectangle().fill(.background).scaleEffect(1.5))
            #if os(macOS)
            .onDeleteCommand {
                downloadManager.remove(selection)
            }
            #endif
            .contextMenu(forSelectionType: BrowserDownload.self) { items in
                contextMenu(items: items)
            } primaryAction: { items in
                #if os(macOS)
                guard let browserDownload = downloadManager.browserDownloads.first(
                    where: { $0 == items.first }
                ) else { return }
                
                NSWorkspace.shared.open(browserDownload.fileURL)
                #endif
            }
            .navigationTitle("Downloads")
            .toolbarTitleDisplayMode(.inline)
            #if os(iOS)
            // Limited to iOS because items are added to window toolbar instead of
            // popover toolbar on macOS
            .toolbar {
                ToolbarItem {
                    Button {
                        downloadManager.clear()
                    } label: {
                        Text("Clear", comment: "Button label.")
                    }
                }
            }
            #endif
        }
        .frame(minWidth: 320, minHeight: 280)
    }
    
    @ViewBuilder
    private func contextMenu(items: Set<BrowserDownload>) -> some View {
        if items.count == 1, let browserDownload = items.first {
            if browserDownload.isFinished {
                #if os(macOS)
                Button {
                    NSWorkspace.shared.open(browserDownload.fileURL)
                } label: {
                    Text("Open File", comment: "Button label.")
                }
                ShowInFinderButton(url: browserDownload.fileURL)
                #else
                ShareButton(item: browserDownload.fileURL)
                #endif
            }
            if let url = browserDownload.wkDownload.originalRequest?.url {
                Button {
                    PasteboardUtility.copyURL(url: url)
                } label: {
                    Text("Copy Address", comment: "Button label.")
                }
            }
            Button {
                downloadManager.remove(browserDownload)
            } label: {
                Text("Remove from List", comment: "Button label.")
            }
        } else {
            Button {
                downloadManager.remove(selection)
            } label: {
                Text("Remove from List", comment: "Button label.")
            }
        }
    }
}
