//
//  Logger+Extensions.swift
//  Den
//
//  Created by Garrett Johnson on 1/1/21.
//  Copyright © 2021 Garrett Johnson
//

import OSLog

extension Logger {
    private static var subsystem = Bundle.main.bundleIdentifier!

    static let main = Logger(subsystem: subsystem, category: "Main")
}
