//
//  SourceManager.swift
//  Den
//
//  Created by Garrett Johnson on 11/12/21.
//  Copyright © 2021 Garrett Johnson. All rights reserved.
//

import Foundation

final class SubscriptionManager: ObservableObject {
    @Published var showingSubscribe: Bool = false

    var feedUrlString: String = ""
    var activePage: Page?

    func showSubscribe(for url: URL? = nil) {
        if
            let url = url,
            var urlComponents = URLComponents(string: url.absoluteString.replacingOccurrences(of: "feed:", with: ""))
        {
            if urlComponents.scheme == nil { urlComponents.scheme = "http" }

            if let urlString = urlComponents.string {
                feedUrlString = urlString
            }
        }

        self.showingSubscribe = true
    }

    func showSubscribe(for page: Page) {
        activePage = page
        self.showingSubscribe = true
    }

    func resetSubscribe() {
        showingSubscribe = false
        feedUrlString = ""
    }
}
