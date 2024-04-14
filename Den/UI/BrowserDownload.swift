//
//  BrowserDownload.swift
//  Den
//
//  Created by Garrett Johnson on 3/26/24.
//  Copyright © 2024 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import Foundation
import OSLog
import WebKit

final class BrowserDownload: Hashable, Identifiable, ObservableObject {
    @Published var wkDownload: WKDownload
    @Published var fileURL: URL
    @Published var isFinished = false
    @Published var error: Error?
    
    init(wkDownload: WKDownload, fileURL: URL) {
        self.wkDownload = wkDownload
        self.fileURL = fileURL
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(wkDownload)
    }
    
    static func == (lhs: BrowserDownload, rhs: BrowserDownload) -> Bool {
        lhs.wkDownload == rhs.wkDownload
    }
}

extension Collection where Element == BrowserDownload {
    func forWKDownload(_ download: WKDownload) -> BrowserDownload? {
        self.first(where: { $0.wkDownload == download })
    }
}
