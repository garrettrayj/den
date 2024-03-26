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
    class Status: Hashable, Identifiable, ObservableObject {
        @Published var wkDownload: WKDownload
        @Published var error: Error?
        @Published var finished = false
        
        init(wkDownload: WKDownload, error: Error? = nil) {
            self.wkDownload = wkDownload
            self.error = error
        }
        
        func hash(into hasher: inout Hasher) {
            hasher.combine(wkDownload)
        }
        
        static func == (lhs: DownloadManager.Status, rhs: DownloadManager.Status) -> Bool {
            lhs.wkDownload == rhs.wkDownload
        }
    }
    
    @Published var statuses: [Status] = []
    
    func clear() {
        statuses.forEach { $0.wkDownload.cancel() }
        statuses = []
    }
    
    func removeDownload(status: Status) {
        status.wkDownload.cancel()
        statuses.removeAll { $0 == status }
    }
    
    func removeDownloads(selection: Set<Status>) {
        selection.forEach { $0.wkDownload.cancel() }
        statuses.removeAll { status in
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
        
        let url = destinationDirectoryURL.appending(path: suggestedFilename)
        
        if FileManager.default.fileExists(atPath: url.path) {
            do {
                try FileManager.default.removeItem(at: url)
            } catch {
                Logger.main.error("Could not delete existing file for download. \(error)")
                return
            }
        }
        
        completionHandler(url)
        
        statuses.insert(Status(wkDownload: download), at: 0)
    }
    
    func downloadDidFinish(_ download: WKDownload) {
        guard let status = statuses.first(where: { $0.wkDownload == download }) else { return }
        status.finished = true
    }
    
    func download(_ download: WKDownload, didFailWithError error: any Error, resumeData: Data?) {
        guard let status = statuses.first(where: { $0.wkDownload == download }) else { return }
        status.error = error
    }
}
