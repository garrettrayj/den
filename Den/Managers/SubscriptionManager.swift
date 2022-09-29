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
    static func showSubscribe(for urlString: String? = nil, page: Page? = nil) {
        var userInfo: [String: Any] = [:]

        if let urlString = urlString {
            userInfo["urlString"] = cleanURLString(urlString)
        }

        if let initialPageObjectID = page?.objectID {
            userInfo["pageObjectID"] = initialPageObjectID
        }

        DispatchQueue.main.async {
            NotificationCenter.default.post(name: .showSubscribe, object: nil, userInfo: userInfo)
        }
    }

    static func cleanURLString(_ urlString: String) -> String {
        urlString
            .replacingOccurrences(of: "feed:", with: "")
            .replacingOccurrences(of: "den:", with: "")
    }
}
