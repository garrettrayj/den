//
//  FaviconResultOperation.swift
//  Den
//
//  Created by Garrett Johnson on 8/7/20.
//  Copyright © 2020 Garrett Johnson. All rights reserved.
//

import CoreData
import OSLog
import UIKit

import func AVFoundation.AVMakeRect

final class SaveFaviconOperation: Operation {
    // Operation inputs
    var workingFeed: WorkingFeedData?
    var webpageFaviconResponse: HTTPURLResponse?
    var webpageFaviconData: Data?
    var defaultFaviconResponse: HTTPURLResponse?
    var defaultFaviconData: Data?

    let faviconSize = CGSize(width: 16 * UIScreen.main.scale, height: 16 * UIScreen.main.scale)

    override func main() {
        if isCancelled { return }

        if
            let httpResponse = webpageFaviconResponse,
            200..<300 ~= httpResponse.statusCode,
            let mimeType = httpResponse.mimeType,
            MIMETypes.FaviconMIMETypes(rawValue: mimeType) != nil,
            let faviconUrl = httpResponse.url,
            let faviconData = webpageFaviconData,
            let image = UIImage(data: faviconData),
            let resizedImage = image.preparingThumbnail(of: faviconSize),
            let filename = saveFavicon(image: resizedImage)
        {
            self.workingFeed?.favicon = faviconUrl
            self.workingFeed?.faviconFile = filename
        } else if
            let httpResponse = defaultFaviconResponse,
            200..<300 ~= httpResponse.statusCode,
            let mimeType = httpResponse.mimeType,
            MIMETypes.FaviconMIMETypes(rawValue: mimeType) != nil,
            let faviconUrl = httpResponse.url,
            let faviconData = defaultFaviconData,
            let image = UIImage(data: faviconData),
            let resizedImage = image.preparingThumbnail(of: faviconSize),
            let filename = self.saveFavicon(image: resizedImage)
        {
            self.workingFeed?.favicon = faviconUrl
            self.workingFeed?.faviconFile = filename
        }

        return
    }

    private func saveFavicon(image: UIImage) -> String? {
        guard let faviconDirectory = FileManager.default.faviconsDirectory else { return nil }

        let filename = UUID().uuidString.appending(".png")
        let filepath = faviconDirectory.appendingPathComponent(filename)

        do {
            try image.pngData()?.write(to: filepath, options: .atomic)
            return filename
        } catch {
            Logger.ingest.error("Unable to save local favicon image: \(error as NSError)")
            return nil
        }
    }
}
