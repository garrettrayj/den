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

    static let feedItemStatus = Notification.Name("feed-item-status")
    static let pageItemStatus = Notification.Name("page-item-status")
    static let profileItemStatus = Notification.Name("profile-item-status")
}

extension NotificationCenter {
    func postItemStatus(
        read: Bool,
        feedObjectID: NSManagedObjectID?,
        pageObjectID: NSManagedObjectID?,
        profileObjectID: NSManagedObjectID?
    ) {
        let userInfo: [String: Bool] = ["read": read]

        post(name: .feedItemStatus, object: feedObjectID, userInfo: userInfo)
        post(name: .pageItemStatus, object: pageObjectID, userInfo: userInfo)
        post(name: .profileItemStatus, object: profileObjectID, userInfo: userInfo)
    }
}
