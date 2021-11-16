//
//  Notification+Extensions.swift
//  Den
//
//  Created by Garrett Johnson on 11/13/21.
//  Copyright © 2021 Garrett Johnson. All rights reserved.
//

import Foundation

extension Notification.Name {
    static let feedWillBeDeleted = Notification.Name("feed-will-be-deleted")
    static let feedQueued = Notification.Name("feed-queued")
    static let feedRefreshed = Notification.Name("feed-refreshed")
    static let pageDeleted = Notification.Name("page-deleted")
    static let pageQueued = Notification.Name("page-queued")
    static let pageRefreshed = Notification.Name("page-refreshed")
}
