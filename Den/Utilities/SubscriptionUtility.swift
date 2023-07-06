//
//  SubscriptionUtility.swift
//  Den
//
//  Created by Garrett Johnson on 11/12/21.
//  Copyright © 2021 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import CoreData

struct SubscriptionUtility {
    static func showSubscribe(for urlString: String? = nil, page: Page? = nil) {
        var userInfo: [String: Any] = [:]

        if let urlString = urlString {
            userInfo["urlString"] = urlString
                .replacingOccurrences(of: "feed:", with: "")
                .replacingOccurrences(of: "den:", with: "")
        }

        if let initialPageObjectID = page?.objectID {
            userInfo["pageObjectID"] = initialPageObjectID
        }

        DispatchQueue.main.async {
            NotificationCenter.default.post(name: .showSubscribe, object: nil, userInfo: userInfo)
        }
    }
}
