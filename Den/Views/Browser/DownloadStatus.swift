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
    @ObservedObject var status: DownloadManager.Status

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
            
            if let error = status.error as? URLError {
                Text(error.localizedDescription)
            } else if status.finished {
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
            } else {
                ProgressView(status.wkDownload.progress)
                Spacer()
                Button {
                    downloadManager.removeDownload(status: status)
                } label: {
                    Label {
                        Text("Cancel")
                    } icon: {
                        Image(systemName: "xmark.circle.fill")
                    }
                }
                .labelStyle(.iconOnly)
                .buttonStyle(.borderless)
                .tint(.secondary)
            }

            Spacer()
            
            Button {
                showInFinder(url: status.wkDownload.progress.fileURL)
            } label: {
                Label {
                    Text("Show in Finder")
                } icon: {
                    Image(systemName: "magnifyingglass.circle.fill")
                }
            }
            .labelStyle(.iconOnly)
            .buttonStyle(.borderless)
            .tint(.secondary)
        }
        .padding(.trailing, 4)
        .frame(height: 56)
    }
    
    private var fileName: String? {
        status.wkDownload.progress.fileURL?.lastPathComponent
    }
    
    private var fileSize: Int64 {
        status.wkDownload.progress.completedUnitCount
    }
    
    private var fileIcon: Image? {
        #if os(macOS)
        guard
            let fileURL = status.wkDownload.progress.fileURL,
            let resourceValues = try? fileURL.resourceValues(forKeys: [.effectiveIconKey]),
            let nsImage = resourceValues.effectiveIcon as? NSImage
        else { return nil }
        
        return Image(nsImage: nsImage)
        #else
        guard
            let fileURL = status.wkDownload.progress.fileURL,
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
