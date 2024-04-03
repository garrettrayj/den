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
    @Published var browserDownloads: [BrowserDownload] = []
    
    func addDownload(wkDownload: WKDownload, fileURL: URL) {
        browserDownloads.insert(BrowserDownload(wkDownload: wkDownload, fileURL: fileURL), at: 0)
    }
    
    func clear() {
        browserDownloads.forEach { $0.wkDownload.cancel() }
        browserDownloads.removeAll()
    }
    
    func remove(_ browserDownload: BrowserDownload) {
        browserDownload.wkDownload.cancel()
        browserDownloads.removeAll(where: { $0 == browserDownload })
    }
    
    func remove(_ selection: Set<BrowserDownload>) {
        selection.forEach {
            $0.wkDownload.cancel()
        }
        browserDownloads.removeAll(where: { selection.contains($0) })
    }
}

extension DownloadManager: WKDownloadDelegate {
    func download(
        _ download: WKDownload,
        willPerformHTTPRedirection response: HTTPURLResponse,
        newRequest request: URLRequest,
        decisionHandler: @escaping (WKDownload.RedirectPolicy) -> Void
    ) {
        decisionHandler(.allow)
    }
    
    func download(
        _ download: WKDownload,
        decideDestinationUsing response: URLResponse,
        suggestedFilename: String,
        completionHandler: @escaping (URL?) -> Void
    ) {
        let fileManager = FileManager.default
        
        let temporaryDirectory = fileManager.temporaryDirectory.appending(
            path: UUID().uuidString,
            directoryHint: .isDirectory
        )
        
        do {
            try fileManager.createDirectory(
                at: temporaryDirectory,
                withIntermediateDirectories: false
            )
        } catch {
            Logger.main.error("Unable to create temporary directory for download.")
            return
        }
        
        let temporaryFileURL = temporaryDirectory.appending(
            path: suggestedFilename,
            directoryHint: .notDirectory
        )
        
        completionHandler(temporaryFileURL)
        addDownload(wkDownload: download, fileURL: temporaryFileURL)
    }
    
    func downloadDidFinish(_ download: WKDownload) {
        guard let browserDownload = browserDownloads.forWKDownload(download) else {
            return
        }
        
        let temporaryFileURL = browserDownload.fileURL
        let finalFilename = temporaryFileURL.lastPathComponent
        let temporaryDirectory = temporaryFileURL.deletingLastPathComponent()
        
        let fileManager = FileManager.default
        
        #if os(macOS)
        guard let downloadsDirectory = try? fileManager.url(
            for: .downloadsDirectory,
            in: .userDomainMask,
            appropriateFor: .downloadsDirectory,
            create: false
        ) else {
            Logger.main.error("Unable to find downloads directory.")
            return
        }
        
        let finalURL = downloadsDirectory.appending(
            path: finalFilename,
            directoryHint: .notDirectory
        )
        
        do {
            if FileManager.default.fileExists(atPath: finalURL.path) {
                try FileManager.default.removeItem(at: finalURL)
            }
            try FileManager.default.moveItem(at: temporaryFileURL, to: finalURL)
        } catch {
            Logger.main.error("Could not move download final path. \(error)")
            return
        }
        
        browserDownload.fileURL = finalURL
        
        if let bundleID = Bundle.main.bundleIdentifier {
            DistributedNotificationCenter.default().post(
                name: NSNotification.Name("com.apple.DownloadFileFinished"),
                object: finalURL.path.replacingOccurrences(
                    of: "Library/Containers/\(bundleID)/Data/",
                    with: ""
                )
            )
        }
        #endif
        
        browserDownload.isFinished = true
    }
    
    func download(_ download: WKDownload, didFailWithError error: any Error, resumeData: Data?) {
        let browserDownload = browserDownloads.forWKDownload(download)
        browserDownload?.error = error
    }
}
