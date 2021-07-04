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
import Combine
import OSLog
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
            let resizedImage = self.resizeImage(imageData: data, size: self.thumbnailSize),
            let filename = self.saveThumbnail(image: resizedImage)
        {
            self.workingFeedItem?.image = url
            self.workingFeedItem?.imageFile = filename
        }
    }

    private func resizeImage(imageData: Data, size: CGSize) -> UIImage? {
        guard let image = UIImage(data: imageData) else {
            return nil
        }

        let renderer = UIGraphicsImageRenderer(size: thumbnailSize)

        let rect = AVMakeRect(aspectRatio: image.size, insideRect: CGRect(origin: .zero, size: thumbnailSize))

        return renderer.image { (_) in
            image.draw(in: CGRect(
                origin: CGPoint(
                    x: thumbnailSize.width / 2 - rect.width / 2,
                    y: thumbnailSize.height / 2 - rect.height / 2
                ),
                size: rect.size
            ))
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
