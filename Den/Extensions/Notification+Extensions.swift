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
    static let appErrored = Notification.Name("app-errored")
    static let downloadStarted = Notification.Name("download-started")
    static let downloadFailed = Notification.Name("download-failed")
    static let downloadFinished = Notification.Name("download-finished")
    static let refreshTriggered = Notification.Name("refresh-triggered")
    static let refreshProgressed = Notification.Name("refresh-progressed")
    static let refreshFinished = Notification.Name("refresh-finished")
    static let refreshStarted = Notification.Name("refresh-started")
}
