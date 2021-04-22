//
//  SaveThumbnailOperation.swift
//  Den
//
//  Created by Garrett Johnson on 4/5/21.
//  Copyright © 2021 Garrett Johnson. All rights reserved.
//

import Foundation
import CoreData
import UIKit
import URLImage
import Combine
import OSLog
import func AVFoundation.AVMakeRect

class SaveThumbnailOperation: Operation {
    // Operation inputs
    var thumbnailResponse: HTTPURLResponse?
    var thumbnailData: Data?
    var workingFeedItem: WorkingFeedItem?
    
    private var thumbnailSize = CGSize(width: 96, height: 64)
    private let acceptableTypes = ["image/gif", "image/jpeg", "image/png"]

    override func main() {
        if isCancelled { return }
        
        if
            let httpResponse = thumbnailResponse,
            200..<300 ~= httpResponse.statusCode,
            let mimeType = httpResponse.mimeType,
            self.acceptableTypes.contains(mimeType),
            let url = httpResponse.url,
            let data = thumbnailData,
            let resizedImage = self.resizeImage(imageData: data, size: self.thumbnailSize),
            let localPath = self.saveFavicon(image: resizedImage)
        {
            self.workingFeedItem?.image = url
            self.workingFeedItem?.imageLocal = localPath
        }
    }
    
    func resizeImage(imageData: Data, size: CGSize) -> UIImage? {
        guard let image = UIImage(data: imageData) else {
            return nil
        }

        let renderer = UIGraphicsImageRenderer(size: size)
        let rect = AVMakeRect(aspectRatio: image.size, insideRect: CGRect(origin: .zero, size: size))
    
        return renderer.image { (context) in
            image.draw(in: rect)
        }
    }
    
    func saveFavicon(image: UIImage) -> URL? {
        let directoryPath = FileManager
            .default
            .urls(for: .applicationSupportDirectory, in: .userDomainMask)
            .last!
            .appendingPathComponent("Thumbnails/")
        
        if !FileManager.default.fileExists(atPath: directoryPath.absoluteString) {
            do {
                try FileManager.default.createDirectory(at: directoryPath, withIntermediateDirectories: true, attributes: nil)
            } catch {
                Logger.ingest.error("\(error.localizedDescription)")
            }
        }
        
        let filename = UUID().uuidString.appending(".png")
        let filepath = directoryPath.appendingPathComponent(filename)

        do {
            try image.pngData()?.write(to: filepath, options: .atomic)
            return filepath
        } catch {
            return nil
        }
    }
}
