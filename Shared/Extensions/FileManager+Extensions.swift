//
//  FileManager+Extensions.swift
//  Den
//
//  Created by Garrett Johnson on 4/22/21.
//  Copyright © 2021 Garrett Johnson. All rights reserved.
//

import Foundation
import OSLog

extension FileManager {
    var appSupportDirectory: URL? {
        do {
            return try self
                .url(
                    for: .applicationSupportDirectory,
                    in: .userDomainMask,
                    appropriateFor: nil,
                    create: true
                )
                .appendingPathComponent("Den")
                .standardizedFileURL
        } catch let error as NSError {
            Logger.main.error("Could not find app support directory: \(error)")
            return nil
        }
    }
}
