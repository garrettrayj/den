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
    public var appSupportDirectory: URL? {
        do {
            return try self
                .url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
                .appendingPathComponent("Den")
                .standardizedFileURL
        } catch let error as NSError {
            Logger.main.error("Could not find app support directory: \(error)")
            return nil
        }
    }

    /**
     @available(*, deprecated, message: "Kingfisher now used for image handling")
     */
    public var faviconsDirectory: URL? {
        guard let appSupportDirectory = self.appSupportDirectory else { return nil }

        return appSupportDirectory.appendingPathComponent("Favicons/")
    }

    /**
     @available(*, deprecated, message: "Kingfisher now used for image handling")
     */
    public var previewsDirectory: URL? {
        guard let appSupportDirectory = self.appSupportDirectory else { return nil }

        return appSupportDirectory.appendingPathComponent("Previews/")
    }

    /**
     @available(*, deprecated, message: "Kingfisher now used for image handling")
     */
    public var thumbnailsDirectory: URL? {
        guard let appSupportDirectory = self.appSupportDirectory else { return nil }

        return appSupportDirectory.appendingPathComponent("Thumbnails/")
    }

    public func cleanupAppDirectories() {
        // Remove old image cache directories
        guard
            let faviconsDirectory = self.faviconsDirectory,
            let previewsDirectory = self.previewsDirectory,
            let thumbnailsDirectory = self.thumbnailsDirectory
        else { return }

        deleteDirectoryIfExists(faviconsDirectory)
        deleteDirectoryIfExists(previewsDirectory)
        deleteDirectoryIfExists(thumbnailsDirectory)
    }

    public func deleteDirectoryIfExists(_ directory: URL) {
        var isDirectory: ObjCBool = true
        let directoryExists = self.fileExists(atPath: directory.path, isDirectory: &isDirectory)

        if directoryExists {
            do {
                try self.removeItem(at: directory)
            } catch let error {
                Logger.main.error("Error removing directory: \(error as NSError)")
            }
        }
    }
}
