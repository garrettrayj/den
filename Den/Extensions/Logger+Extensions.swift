//
//  Logger+Extensions.swift
//  Den
//
//  Created by Garrett Johnson on 1/1/21.
//  Copyright © 2021 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import Foundation
import OSLog

extension Logger {
    private static var subsystem = Bundle.main.bundleIdentifier!

    /**
     Main application log for general messages
     */
    static let main = Logger(subsystem: subsystem, category: "Main")

    /**
     Ingest log for messages related to downloading feed content
     */
    static let ingest = Logger(subsystem: subsystem, category: "Ingest")
}
