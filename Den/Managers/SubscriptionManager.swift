//
//  SubscriptionManager.swift
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
        if let url = url {
            let urlString = url.absoluteString
                .replacingOccurrences(of: "feed:", with: "")
                .replacingOccurrences(of: "den:", with: "")

            if var urlComponents = URLComponents(string: urlString) {
                if urlComponents.scheme == nil { urlComponents.scheme = "http" }
                if let urlString = urlComponents.string {
                    feedUrlString = urlString
                }
            }
        }

        self.showingSubscribe = true
    }

    func resetSubscribe() {
        showingSubscribe = false
        feedUrlString = ""
    }
}
