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

    override func main() {
        if isCancelled { return }

        if
            let httpResponse = webpageFaviconResponse,
            let data = webpageFaviconData,
            let saveResult = prepareFavicon(httpResponse: httpResponse, data: data)
        {
            self.workingFeed?.favicon = saveResult.url
            self.workingFeed?.faviconFile = saveResult.filename
        } else if
            let httpResponse = defaultFaviconResponse,
            let data = defaultFaviconData,
            let saveResult = prepareFavicon(httpResponse: httpResponse, data: data)
        {
            self.workingFeed?.favicon = saveResult.url
            self.workingFeed?.faviconFile = saveResult.filename
        }

        return
    }

    private func prepareFavicon(httpResponse: HTTPURLResponse, data: Data) -> (filename: String, url: URL)? {
        if
            200..<300 ~= httpResponse.statusCode,
            let mimeType = httpResponse.mimeType,
            FaviconMIMEType(rawValue: mimeType) != nil,
            let url = httpResponse.url,
            let image = UIImage(data: data),
            let filename = saveFavicon(image: image.resizedToFit(size: ImageSize.favicon))
        {
            return (filename, url)
        }

        return nil
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
