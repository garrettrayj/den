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
import WebKit

class BrowserDownload: Hashable, Identifiable, ObservableObject {
    @Published var wkDownload: WKDownload
    @Published var error: Error?
    
    var finalURL: URL? {
        // Remove .download extension
        wkDownload.progress.fileURL?.deletingPathExtension()
    }
    
    init(wkDownload: WKDownload) {
        self.wkDownload = wkDownload
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(wkDownload)
    }
    
    static func == (lhs: BrowserDownload, rhs: BrowserDownload) -> Bool {
        lhs.wkDownload == rhs.wkDownload
    }
}
