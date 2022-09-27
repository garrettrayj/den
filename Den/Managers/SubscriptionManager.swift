//
//  SubscriptionManager.swift
//  Den
//
//  Created by Garrett Johnson on 11/12/21.
//  Copyright © 2021 Garrett Johnson. All rights reserved.
//

import Foundation
import CoreData

struct SubscriptionManager {
    static func showSubscribe(for url: URL? = nil, page: Page? = nil) {
        var userInfo: [String: Any] = [:]

        if let url = url {
            let urlString = url.absoluteString
                .replacingOccurrences(of: "feed:", with: "")
                .replacingOccurrences(of: "den:", with: "")

            if var urlComponents = URLComponents(string: urlString) {
                if urlComponents.scheme == nil { urlComponents.scheme = "http" }
                if let urlString = urlComponents.string {
                    userInfo["urlString"] = urlString
                }
            }
        }

        if let initialPageObjectID = page?.objectID {
            userInfo["pageObjectID"] = initialPageObjectID
        }

        DispatchQueue.main.async {
            NotificationCenter.default.post(name: .showSubscribe, object: nil, userInfo: userInfo)
        }
    }
}
