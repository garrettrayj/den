//
//  SubscribeManager.swift
//  Den
//
//  Created by Garrett Johnson on 11/12/21.
//  Copyright © 2021 Garrett Johnson. All rights reserved.
//

import Foundation

final class SubscribeManager: ObservableObject {
    @Published var currentPageId: String?
    @Published var showingAddSubscription: Bool = false
    @Published var openedUrlString: String = ""

    func showAddSubscription(to url: URL? = nil) {
        if
            let url = url,
            var urlComponents = URLComponents(string: url.absoluteString.replacingOccurrences(of: "feed:", with: ""))
        {
            if urlComponents.scheme == nil {
                urlComponents.scheme = "http"
            }

            if let urlString = urlComponents.string {
                openedUrlString = urlString
            }
        }

        self.showingAddSubscription = true
    }

    func resetSubscribe() {
        showingAddSubscription = false
        openedUrlString = ""
    }
}
