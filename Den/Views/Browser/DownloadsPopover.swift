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
        List(selection: $selection) {
            Section {
                ForEach(downloadManager.browserDownloads) { browserDownload in
                    DownloadStatus(browserDownload: browserDownload)
                        .tag(browserDownload)
                        .listRowInsets(.init(top: 8, leading: 8, bottom: 8, trailing: 8))
                }
            } header: {
                HStack {
                    Text("Downloads", comment: "Popover title.")
                    Spacer()
                    Button {
                        downloadManager.clear()
                    } label: {
                        Text("Clear", comment: "Button label.")
                    }
                }
                #if os(macOS)
                .padding(.vertical, 4)
                #else
                .padding(.bottom, 4)
                #endif
            }
        }
        .frame(minWidth: 320, minHeight: 280)
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
            guard
                let browserDownload = downloadManager.browserDownloads.first(
                    where: { $0 == items.first }
                )
            else {
                return
            }
            
            #if os(macOS)
            NSWorkspace.shared.open(browserDownload.fileURL)
            #endif
        }
    }
    
    @ViewBuilder
    private func contextMenu(items: Set<BrowserDownload>) -> some View {
        if items.count == 1, let browserDownload = items.first {
            if browserDownload.isFinished {
                #if os(macOS)
                Button {
                    NSWorkspace.shared.open(browserDownload.fileURL)
                } label: {
                    Text("Open")
                }
                Button {
                    if browserDownload.fileURL.hasDirectoryPath {
                        NSWorkspace.shared.selectFile(
                            nil,
                            inFileViewerRootedAtPath: browserDownload.fileURL.path
                        )
                    } else {
                        NSWorkspace.shared.activateFileViewerSelecting([browserDownload.fileURL])
                    }
                } label: {
                    Text("Show in Finder")
                }
                #endif
            }
            if let url = browserDownload.wkDownload.originalRequest?.url {
                Button {
                    PasteboardUtility.copyURL(url: url)
                } label: {
                    Text("Copy Address")
                }
            }
            Button {
                downloadManager.remove(browserDownload)
            } label: {
                Text("Remove from List")
            }
        } else {
            Button {
                downloadManager.remove(selection)
            } label: {
                Text("Remove from List")
            }
        }
    }
}
