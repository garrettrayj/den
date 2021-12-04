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

    private let acceptableTypes = ["image/gif", "image/jpeg", "image/png"]

    override func main() {
        if isCancelled { return }

        guard
            let httpResponse = httpResponse,
            200..<300 ~= httpResponse.statusCode,
            let mimeType = httpResponse.mimeType,
            self.acceptableTypes.contains(mimeType),
            let url = httpResponse.url,
            let data = data,
            let originalImage = UIImage(data: data)
        else { return }

        workingItem?.image = url
        workingItem?.imageWidth = Int32(originalImage.size.width)
        workingItem?.imageHeight = Int32(originalImage.size.height)

        let resizedPreviewImage = originalImage.aspectFittedToWidth(396)
        if
            let previewsDirectory = FileManager.default.previewsDirectory,
            let imagePreview = saveImage(image: resizedPreviewImage, directory: previewsDirectory)
        {
            self.workingItem?.imagePreview = imagePreview
        }

        if
            let thumbnailsDirectory = FileManager.default.thumbnailsDirectory,
            let resizedThumbnailImage = originalImage.preparingThumbnail(of: thumbnailSize),
            let imageThumbnail = saveImage(image: resizedThumbnailImage, directory: thumbnailsDirectory)
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
