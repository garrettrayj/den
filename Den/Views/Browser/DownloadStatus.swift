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
    @Binding var downloads: [WKDownload]
    
    var download: WKDownload
    
    @State private var error: Error?
    @State private var finished: Bool = false
    
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
            if let error = error as? URLError {
                Text(error.localizedDescription)
            } else if finished {
                HStack {
                    fileIcon
                    
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
                }
                
                Spacer()
                
                Button {
                    showInFinder(url: download.progress.fileURL)
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
            } else {
                ProgressView(download.progress)
            }
            
        }
        .padding(.vertical, 8)
        .padding(.horizontal)
        .onReceive(
            NotificationCenter.default.publisher(for: .downloadFinished, object: download)
        ) { notification in
            finished = true
        }
        .onReceive(
            NotificationCenter.default.publisher(for: .downloadFailed, object: download)
        ) { notification in
            guard let downloadError = notification.userInfo?["error"] as? Error else {
                return
            }
            
            error = downloadError
        }
    }
    
    private var fileName: String? {
        download.progress.fileURL?.lastPathComponent
    }
    
    private var fileSize: Int64 {
        download.progress.completedUnitCount
    }
    
    private var fileIcon: Image? {
        #if os(macOS)
        guard
            let fileURL = download.progress.fileURL,
            let resourceValues = try? fileURL.resourceValues(forKeys: [.effectiveIconKey]),
            let nsImage = resourceValues.effectiveIcon as? NSImage
        else { return nil }
        
        return Image(nsImage: nsImage)
        #else
        guard
            let fileURL = download.progress.fileURL,
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
