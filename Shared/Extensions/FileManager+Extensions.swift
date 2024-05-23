//
//  FileManager+Extensions.swift
//  Den
//
//  Created by Garrett Johnson on 4/22/21.
//  Copyright © 2021 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import Foundation
import OSLog

extension FileManager {
    var appSupportDirectory: URL? {
        do {
            return try self.url(
                for: .applicationSupportDirectory,
                in: .userDomainMask,
                appropriateFor: nil,
                create: true
            )
            .appending(path: "Den", directoryHint: .isDirectory)
        } catch {
            Logger.main.error("Could not find app support directory: \(error)")
            return nil
        }
    }
    
    var groupSupportDirectory: URL? {
        self
            .containerURL(forSecurityApplicationGroupIdentifier: AppGroup.den.rawValue)?
            .appending(path: "Library/Application Support", directoryHint: .isDirectory)
    }
}
