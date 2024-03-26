//
//  DownloadsButton.swift
//  Den
//
//  Created by Garrett Johnson on 3/22/24.
//  Copyright © 2024 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

struct DownloadsButton: View {
    @ObservedObject var downloadManager: DownloadManager
    
    @State private var showingPopover = false
    
    @State private var selection = Set<DownloadManager.Status>()
    
    var body: some View {
        Button {
            showingPopover = true
        } label: {
            Label {
                Text("Downloads", comment: "Button label.")
            } icon: {
                Image(systemName: "arrow.down.circle")
            }
        }
        .popover(isPresented: $showingPopover, arrowEdge: .top) {
            VStack {
                ZStack {
                    HStack {
                        Spacer()
                        Text("Downloads", comment: "Popover title.")
                        Spacer()
                    }
                    HStack {
                        Spacer()
                        Button {
                            downloadManager.clear()
                        } label: {
                            Text("Clear", comment: "Button label.")
                        }
                    }
                }
                .padding([.top, .horizontal], 8)
                
                List(selection: $selection) {
                    ForEach(downloadManager.statuses) { status in
                        DownloadStatus(downloadManager: downloadManager, status: status).tag(status)
                    }
                }
                .onDeleteCommand {
                    downloadManager.removeDownloads(selection: selection)
                }
                .scrollContentBackground(.hidden)
                .contextMenu(forSelectionType: DownloadManager.Status.self) { items in
                    contextMenu(items: items)
                } primaryAction: { items in
                    guard
                        let download = downloadManager.statuses.first(where: { $0 == items.first }),
                        let url = download.wkDownload.progress.fileURL
                    else {
                        return
                    }
                    
                    #if os(macOS)
                    NSWorkspace.shared.open(url)
                    #endif
                }
            }
            .frame(minWidth: 320, minHeight: 280)
        }
    }
    
    var listMinHeight: CGFloat {
        if downloadManager.statuses.count == 1 {
            56 + 16
        } else {
            CGFloat(downloadManager.statuses.count * 56) + 16
        }
    }
    
    var listMaxHeight: CGFloat {
        56 * 6 + 16
    }
    
    @ViewBuilder
    private func contextMenu(items: Set<DownloadManager.Status>) -> some View {
        if items.count == 1, let status = downloadManager.statuses.first(where: { $0 == items.first }) {
            Button {
                guard let url = status.wkDownload.progress.fileURL else {
                    return
                }
                #if os(macOS)
                NSWorkspace.shared.open(url)
                #endif
            } label: {
                Text("Open")
            }
            
            Button {
                guard let url = status.wkDownload.progress.fileURL else { return }

                #if os(macOS)
                if url.hasDirectoryPath {
                    NSWorkspace.shared.selectFile(nil, inFileViewerRootedAtPath: url.path)
                } else {
                    NSWorkspace.shared.activateFileViewerSelecting([url])
                }
                #endif
            } label: {
                Text("Show in Finder")
            }
            
            Button {
                guard let url = status.wkDownload.originalRequest?.url else { return }
                PasteboardUtility.copyURL(url: url)
            } label: {
                Text("Copy Address")
            }
            
            Button {
                downloadManager.removeDownload(status: status)
            } label: {
                Text("Remove from List")
            }
        } else {
            Button {
                downloadManager.removeDownloads(selection: selection)
            } label: {
                Text("Remove from List")
            }
        }
    }
}
