//
//  FaviconResultOperation.swift
//  Den
//
//  Created by Garrett Johnson on 8/7/20.
//  Copyright © 2020 Garrett Johnson. All rights reserved.
//

import Foundation
import CoreData
import UIKit
import URLImage
import Combine
import OSLog
import func AVFoundation.AVMakeRect

class SaveFaviconOperation: Operation {
    // Operation inputs
    var workingFeed: WorkingFeed?
    var webpageFaviconResponse: HTTPURLResponse?
    var webpageFaviconData: Data?
    var defaultFaviconResponse: HTTPURLResponse?
    var defaultFaviconData: Data?
    
    private var faviconSize = CGSize(width: 16, height: 16)
    private let acceptableTypes = ["image/x-icon", "image/vnd.microsoft.icon", "image/gif", "image/png", "image/jpeg"]

    override func main() {
        if isCancelled { return }
        
        if
            let httpResponse = webpageFaviconResponse,
            200..<300 ~= httpResponse.statusCode,
            let mimeType = httpResponse.mimeType,
            self.acceptableTypes.contains(mimeType),
            let faviconUrl = httpResponse.url,
            let faviconData = webpageFaviconData,
            let resizedImage = self.resizeImage(imageData: faviconData, size: self.faviconSize),
            let localPath = self.saveFavicon(image: resizedImage)
        {
            self.workingFeed?.favicon = faviconUrl
            self.workingFeed?.faviconLocal = localPath
        } else if
            let httpResponse = defaultFaviconResponse,
            200..<300 ~= httpResponse.statusCode,
            let mimeType = httpResponse.mimeType,
            self.acceptableTypes.contains(mimeType),
            let faviconUrl = httpResponse.url,
            let faviconData = defaultFaviconData,
            let resizedImage = self.resizeImage(imageData: faviconData, size: self.faviconSize),
            let localPath = self.saveFavicon(image: resizedImage)
        {
            self.workingFeed?.favicon = faviconUrl
            self.workingFeed?.faviconLocal = localPath
        }
        
        return
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
        guard let faviconDirectory = FileManager.default.faviconsDirectory() else { return nil }
        
        let filename = UUID().uuidString.appending(".png")
        let filepath = faviconDirectory.appendingPathComponent(filename)

        do {
            try image.pngData()?.write(to: filepath, options: .atomic)
            return filepath
        } catch {
            Logger.ingest.error("Unable to save local favicon image: \(error as NSError)")
            return nil
        }
    }
}
