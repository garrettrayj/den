//
//  Logger+Extensions.swift
//  Den
//
//  Created by Garrett Johnson on 1/1/21.
//  Copyright © 2021 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import OSLog

extension Logger {
    private static let subsystem = Bundle.main.bundleIdentifier!

    static let main = Logger(subsystem: subsystem, category: "Main")
    static let widgets = Logger(subsystem: subsystem, category: "Widgets")
}
