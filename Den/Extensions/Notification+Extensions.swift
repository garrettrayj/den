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
    static let pageRefreshed = Notification.Name("page-refreshed")
    static let profileRefreshed = Notification.Name("profile-refreshed")

    static let itemStatus = Notification.Name("item-status")
}

extension NotificationCenter {
    func postItemStatus(
        read: Bool,
        itemObjectID: NSManagedObjectID?,
        feedObjectID: NSManagedObjectID?,
        pageObjectID: NSManagedObjectID?,
        profileObjectID: NSManagedObjectID?
    ) {
        let userInfo: [String: Any] = [
            "read": read,
            "itemObjectID": itemObjectID ?? "",
            "feedObjectID": feedObjectID ?? "",
            "pageObjectID": pageObjectID ?? "",
            "profileObjectID": profileObjectID ?? ""
        ]
        post(name: .itemStatus, object: nil, userInfo: userInfo)
    }
}
