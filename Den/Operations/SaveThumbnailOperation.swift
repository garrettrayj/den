//
//  SaveThumbnailOperation.swift
//  Den
//
//  Created by Garrett Johnson on 4/5/21.
//  Copyright © 2021 Garrett Johnson. All rights reserved.
//

import CoreData
import OSLog
import UIKit

import func AVFoundation.AVMakeRect

final class SaveThumbnailOperation: Operation {
    // Operation inputs
    var thumbnailResponse: HTTPURLResponse?
    var thumbnailData: Data?
    var workingFeedItem: WorkingItem?

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
            let originalImage = UIImage(data: data),
            let resizedImage = originalImage.resizedToFill(size: thumbnailSize),
            let filename = self.saveThumbnail(image: resizedImage)
        {
            self.workingFeedItem?.image = url
            self.workingFeedItem?.imageFile = filename
        }
    }

    private func saveThumbnail(image: UIImage) -> String? {
        guard let thumbnailDirectory = FileManager.default.thumbnailsDirectory else { return nil }

        let filename = UUID().uuidString.appending(".png")
        let filepath = thumbnailDirectory.appendingPathComponent(filename)

        do {
            try image.pngData()?.write(to: filepath, options: .atomic)
            return filename
        } catch {
            Logger.ingest.error("Unable to save local thumbnail image: \(error as NSError)")
            return nil
        }
    }

}
