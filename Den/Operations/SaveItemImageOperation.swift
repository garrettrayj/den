//
//  SaveItemImageOperation.swift
//  Den
//
//  Created by Garrett Johnson on 4/5/21.
//  Copyright © 2021 Garrett Johnson. All rights reserved.
//

import CoreData
import OSLog
import UIKit

final class SaveItemImageOperation: Operation {
    // Operation inputs
    var httpResponse: HTTPURLResponse?
    var data: Data?
    var workingItem: WorkingItem?

    private var thumbnailSize = CGSize(width: 96 * 2, height: 64 * 2)

    override func main() {
        if isCancelled { return }

        guard
            let httpResponse = httpResponse,
            200..<300 ~= httpResponse.statusCode,
            let mimeType = httpResponse.mimeType,
            ImageMIMEType(rawValue: mimeType) != nil,
            let url = httpResponse.url,
            let data = data,
            let originalImage = UIImage(data: data)
        else { return }

        workingItem?.image = url
        workingItem?.imageWidth = Int32(originalImage.size.width)
        workingItem?.imageHeight = Int32(originalImage.size.height)

        if
            let directory = FileManager.default.previewsDirectory,
            let imagePreview = saveImage(
                image: originalImage.aspectFittedToWidth(ImageSize.preview.width),
                directory: directory
            )
        {
            self.workingItem?.imagePreview = imagePreview
        }

        if
            let directory = FileManager.default.thumbnailsDirectory,
            let imageThumbnail = saveImage(
                image: originalImage.resizedToFill(size: ImageSize.thumbnail),
                directory: directory
            )
        {
            self.workingItem?.imageThumbnail = imageThumbnail
        }
    }

    private func saveImage(image: UIImage, directory: URL) -> String? {
        let filename = UUID().uuidString.appending(".png")
        let filepath = directory.appendingPathComponent(filename)

        do {
            try image.pngData()?.write(to: filepath, options: .atomic)
            return filename
        } catch {
            Logger.ingest.error("Unable to save local thumbnail image: \(error as NSError)")
            return nil
        }
    }
}
