//
//  Notification+Extensions.swift
//  Den
//
//  Created by Garrett Johnson on 11/13/21.
//  Copyright © 2021 Garrett Johnson. All rights reserved.
//

import Foundation

extension Notification.Name {
    static let refreshStarted = Notification.Name("refresh-started")
    static let refreshFinished = Notification.Name("refresh-finished")
    static let feedUpdated = Notification.Name("feed-updated")
    static let itemUnread = Notification.Name("item-unread")
    static let itemRead = Notification.Name("item-read")
}
