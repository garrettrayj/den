//
//  ScreenManager.swift
//  Den
//
//  Created by Garrett Johnson on 9/5/20.
//  Copyright © 2020 Garrett Johnson. All rights reserved.
//

import CoreData
import SwiftUI

final class SubscriptionManager: ObservableObject {
    @Published var currentPageId: UUID?
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

    func reset() {
        showingAddSubscription = false
        openedUrlString = ""
    }
}
