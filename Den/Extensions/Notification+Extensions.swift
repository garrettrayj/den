//
//  Notification+Extensions.swift
//  Den
//
//  Created by Garrett Johnson on 11/13/21.
//  Copyright © 2021 Garrett Johnson. All rights reserved.
//

import Foundation
import CoreData

extension Notification.Name {
    static let refreshStarted = Notification.Name("refresh-started")
    static let refreshFinished = Notification.Name("refresh-finished")

    static let feedRefreshed = Notification.Name("feed-refreshed")
    static let pagesRefreshed = Notification.Name("pages-refreshed")

    static let itemStatus = Notification.Name("item-status")

    static let showSubscribe = Notification.Name("show-subscribe")
    static let showCrashMessage = Notification.Name("show-crash-message")
}

extension NotificationCenter {
    func postItemStatus(item: Item) {
        let userInfo: [String: Any] = [
            "read": item.read,
            "itemObjectID": item.objectID,
            "feedObjectID": item.feedData?.feed?.objectID ?? "",
            "pageObjectID": item.feedData?.feed?.page?.objectID ?? "",
            "profileObjectID": item.feedData?.feed?.page?.profile?.objectID ?? ""
        ]
        post(name: .itemStatus, object: nil, userInfo: userInfo)
    }
}
