//
//  SourceManager.swift
//  Den
//
//  Created by Garrett Johnson on 11/12/21.
//  Copyright © 2021 Garrett Johnson. All rights reserved.
//

import Foundation

final class SourceManager: ObservableObject {
    @Published var currentPageId: String?
    @Published var showingSheet: Bool = false
    @Published var feedUrlString: String = ""

    func showSheet(for url: URL? = nil) {
        if
            let url = url,
            var urlComponents = URLComponents(string: url.absoluteString.replacingOccurrences(of: "feed:", with: ""))
        {
            if urlComponents.scheme == nil {
                urlComponents.scheme = "http"
            }

            if let urlString = urlComponents.string {
                feedUrlString = urlString
            }
        }

        self.showingSheet = true
    }

    func resetSubscribe() {
        showingSheet = false
        feedUrlString = ""
    }
}
