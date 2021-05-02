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
        } catch let error as NSError  {
            Logger.main.error("Could not find favicon directory: \(error)")
            return nil
        }
    }
    
    public var faviconsDirectory: URL? {
        guard let appSupportDirectory = self.appSupportDirectory else { return nil }
        
        return appSupportDirectory.appendingPathComponent("Favicons/")
    }
    
    public var thumbnailsDirectory: URL? {
        guard let appSupportDirectory = self.appSupportDirectory else { return nil }
        
        return appSupportDirectory.appendingPathComponent("Thumbnails/")
    }
    
    public func initAppDirectories() {
        guard
            let faviconsDirectory = self.faviconsDirectory,
            let thumbnailsDirectory = self.thumbnailsDirectory
        else { return }
        
        self.createDirectoryIfMissing(faviconsDirectory)
        self.createDirectoryIfMissing(thumbnailsDirectory)
    }
    
    public func createDirectoryIfMissing(_ directory: URL) {
        var isDirectory: ObjCBool = true
        let directoryExists = self.fileExists(atPath: directory.path, isDirectory: &isDirectory)
        
        if !directoryExists {
            do {
                try self.createDirectory(at: directory, withIntermediateDirectories: true, attributes: nil)
            } catch let error {
                Logger.main.error("Error creating directory: \(error as NSError)")
            }
        }
    }
    
}
