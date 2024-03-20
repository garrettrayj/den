//
//  BrowserDownloads.swift
//  Den
//
//  Created by Garrett Johnson on 3/19/24.
//  Copyright © 2024 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI
import WebKit

struct BrowserDownloads: View {
    @State private var downloads: [WKDownload] = []
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ForEach(downloads, id: \.self) { download in
                Divider()
                DownloadStatus(downloads: $downloads, download: download)
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .downloadStarted)) { notification in
            if let download = notification.object as? WKDownload {
                downloads.append(download)
            }
        }
    }
}
