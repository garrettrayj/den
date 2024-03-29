//
//  DownloadStatus.swift
//  Den
//
//  Created by Garrett Johnson on 3/19/24.
//  Copyright © 2024 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI
import WebKit

struct DownloadStatus: View {
    @Environment(\.openURL) private var openURL
    
    @ObservedObject var downloadManager: DownloadManager
    @ObservedObject var download: BrowserDownload

    static let filesSizeFormatter: ByteCountFormatter = {
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = .useAll
        formatter.countStyle = .file
        formatter.includesUnit = true
        formatter.isAdaptive = true

        return formatter
    }()
    
    var body: some View {
        HStack {
            fileIcon
            
            if let error = download.error as? URLError {
                Text(error.localizedDescription)
            } else if download.wkDownload.progress.isFinished {
                VStack(alignment: .leading) {
                    if let fileName = fileName {
                        Text(verbatim: fileName)
                    } else {
                        Text("Unknown", comment: "Download file name unavailable.")
                    }
                    
                    Text(verbatim: DownloadStatus.filesSizeFormatter.string(
                        fromByteCount: fileSize
                    )).font(.footnote)
                }
                .lineLimit(2)
                Spacer()
                Button {
                    showInFinder(url: download.finalURL)
                } label: {
                    Label {
                        Text("Show in Finder")
                    } icon: {
                        Image(systemName: "magnifyingglass.circle.fill")
                    }
                }
                .tint(.secondary)
            } else {
                ProgressView(download.wkDownload.progress)
                Spacer()
                Button {
                    downloadManager.removeDownload(download: download)
                } label: {
                    Label {
                        Text("Cancel")
                    } icon: {
                        Image(systemName: "xmark.circle.fill")
                    }
                }
                .tint(.secondary)
                Button {
                    showInFinder(url: download.wkDownload.progress.fileURL)
                } label: {
                    Label {
                        Text("Show in Finder")
                    } icon: {
                        Image(systemName: "magnifyingglass.circle.fill")
                    }
                }
                .tint(.secondary)
            }
        }
        .labelStyle(.iconOnly)
        .buttonStyle(.borderless)
        .padding(.trailing, 4)
        .frame(height: 56)
    }
    
    private var fileName: String? {
        download.wkDownload.progress.fileURL?.deletingPathExtension().lastPathComponent
    }
    
    private var fileSize: Int64 {
        download.wkDownload.progress.completedUnitCount
    }
    
    private var fileIcon: Image? {
        #if os(macOS)
        guard
            let fileURL = download.finalURL,
            let resourceValues = try? fileURL.resourceValues(forKeys: [.effectiveIconKey]),
            let nsImage = resourceValues.effectiveIcon as? NSImage
        else { return nil }
        
        return Image(nsImage: nsImage)
        #else
        guard
            let fileURL = download.finalURL,
            let uiImage = UIDocumentInteractionController(url: fileURL).icons.first
        else { return nil }
        
        return Image(uiImage: uiImage)
        #endif
    }
    
    private func showInFinder(url: URL?) {
        guard let url = url else { return }
        
        #if os(macOS)
        if url.hasDirectoryPath {
            NSWorkspace.shared.selectFile(nil, inFileViewerRootedAtPath: url.path)
        } else {
            NSWorkspace.shared.activateFileViewerSelecting([url])
        }
        #endif
    }
}
