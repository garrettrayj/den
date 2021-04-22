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
    
    public func thumbnailsDirectory() -> URL? {
        do {
            let directoryUrl = try self.url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
                .appendingPathComponent("Thumbnails/")
            
            var isDirectory: ObjCBool = true
            let directoryExists = self.fileExists(atPath: directoryUrl.path, isDirectory: &isDirectory)
            
            if !directoryExists {
                do {
                    try self.createDirectory(at: directoryUrl, withIntermediateDirectories: false, attributes: nil)
                } catch let error as NSError {
                    Logger.ingest.error("\(error)")
                }
            }
            
            return directoryUrl
        } catch let error as NSError  {
            Logger.main.error("Could not find favicon directory: \(error)")
        }
        
        return nil
    }
    
    public func faviconsDirectory() -> URL? {
        do {
            let directoryUrl = try self.url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
                .appendingPathComponent("Favicons/")
            
            var isDirectory: ObjCBool = true
            let directoryExists = self.fileExists(atPath: directoryUrl.path, isDirectory: &isDirectory)
            
            if !directoryExists {
                do {
                    try self.createDirectory(at: directoryUrl, withIntermediateDirectories: false, attributes: nil)
                } catch let error as NSError {
                    Logger.ingest.error("\(error)")
                }
            }
            
            return directoryUrl
        } catch let error as NSError  {
            Logger.main.error("Could not find favicon directory: \(error)")
        }
        
        return nil
    }
}
