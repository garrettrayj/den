//
//  DownloadManager.swift
//  Den
//
//  Created by Garrett Johnson on 3/21/24.
//  Copyright © 2024 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import Foundation
import WebKit
import OSLog

class DownloadManager: NSObject, ObservableObject {
    @Published var downloads: [BrowserDownload] = []
    
    func clear() {
        downloads.forEach { $0.wkDownload.cancel() }
        downloads = []
    }
    
    func removeDownload(download: BrowserDownload) {
        download.wkDownload.cancel()
        downloads.removeAll { $0 == download }
    }
    
    func removeDownloads(selection: Set<BrowserDownload>) {
        selection.forEach { $0.wkDownload.cancel() }
        downloads.removeAll { status in
            selection.contains(status)
        }
    }
}

extension DownloadManager: WKDownloadDelegate {
    func download(
        _ download: WKDownload,
        decideDestinationUsing response: URLResponse,
        suggestedFilename: String,
        completionHandler: @escaping (URL?) -> Void
    ) {
        guard let destinationDirectoryURL = try? FileManager.default.url(
            for: .downloadsDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: true
        ) else { return }
        
        let url = destinationDirectoryURL
            .appending(path: suggestedFilename)
            .appendingPathExtension("download")
        
        if FileManager.default.fileExists(atPath: url.path) {
            do {
                try FileManager.default.removeItem(at: url)
            } catch {
                Logger.main.error("Could not delete existing file download. \(error)")
                return
            }
        }
        
        completionHandler(url)
        
        downloads.insert(BrowserDownload(wkDownload: download), at: 0)
    }
    
    func downloadDidFinish(_ download: WKDownload) {
        guard
            let browserDownload = downloads.first(where: { $0.wkDownload == download }),
            let intermediateURL = download.progress.fileURL,
            let finalURL = browserDownload.finalURL
        else { return }
        
        if FileManager.default.fileExists(atPath: finalURL.path) {
            do {
                try FileManager.default.removeItem(at: finalURL)
            } catch {
                Logger.main.error("Could not delete existing file at download final path. \(error)")
                return
            }
        }
        
        do {
            try FileManager.default.moveItem(at: intermediateURL, to: finalURL)
        } catch {
            Logger.main.error("Could not rename download to final path. \(error)")
        }
        
        browserDownload.objectWillChange.send()
    }
    
    func download(_ download: WKDownload, didFailWithError error: any Error, resumeData: Data?) {
        guard let status = downloads.first(where: { $0.wkDownload == download }) else { return }
        status.error = error
    }
}
