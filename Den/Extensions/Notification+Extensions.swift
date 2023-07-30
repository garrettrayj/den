//
//  Notification+Extensions.swift
//  Den
//
//  Created by Garrett Johnson on 11/13/21.
//  Copyright © 2021 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import Foundation

extension Notification.Name {
    static let appCrashed = Notification.Name("app-crashed")
    static let feedRefreshed = Notification.Name("feed-refreshed")
    static let pagesRefreshed = Notification.Name("pages-refreshed")
    static let refreshFinished = Notification.Name("refresh-finished")
    static let refreshStarted = Notification.Name("refresh-started")
}
