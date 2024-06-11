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
    
    @Environment(DownloadManager.self) private var downloadManager
    
    var browserDownload: BrowserDownload

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
            
            if let error = browserDownload.error as? URLError {
                Text(error.localizedDescription)
            } else if browserDownload.wkDownload.progress.isFinished {
                VStack(alignment: .leading) {
                    if let fileName {
                        Text(fileName)
                    } else {
                        Text("Unknown", comment: "Download file name unavailable.")
                    }
                    
                    Text(DownloadStatus.filesSizeFormatter.string(
                        fromByteCount: fileSize
                    )).font(.footnote)
                }
                .lineLimit(2)
                Spacer()
                #if os(macOS)
                ShowInFinderButton(url: browserDownload.fileURL).tint(.secondary)
                #else
                ShareButton(item: browserDownload.fileURL)
                #endif
            } else {
                ProgressView(browserDownload.wkDownload.progress)
                Spacer()
                Button {
                    downloadManager.remove(browserDownload)
                } label: {
                    Label {
                        Text("Cancel", comment: "Button label.")
                    } icon: {
                        Image(systemName: "xmark.circle.fill")
                    }
                }
                .tint(.secondary)
            }
        }
        .labelStyle(.iconOnly)
        .buttonStyle(.borderless)
    }
    
    private var fileName: String? {
        browserDownload.fileURL.lastPathComponent
    }
    
    private var fileSize: Int64 {
        browserDownload.wkDownload.progress.completedUnitCount
    }
    
    private var fileIcon: Image? {
        #if os(macOS)
        guard
            let resourceValues = try? browserDownload.fileURL.resourceValues(
                forKeys: [.effectiveIconKey]
            ),
            let nsImage = resourceValues.effectiveIcon as? NSImage
        else {
            return nil
        }
        
        return Image(nsImage: nsImage)
        #else
        guard let uiImage = UIDocumentInteractionController(
            url: browserDownload.fileURL
        ).icons.first else {
            return nil
        }
        
        return Image(uiImage: uiImage)
        #endif
    }
}
