//
//  Item+CoreDataClass.swift
//  Den
//
//  Created by Garrett Johnson on 7/30/20.
//  Copyright © 2020 Garrett Johnson. All rights reserved.
//

import CoreData
import HTMLEntities
import SwiftUI
import OSLog

@objc(Item)
public class Item: NSManagedObject {
    public var read: Bool {
        guard let values = value(forKey: "history") as? [History] else { return false }
        return !values.isEmpty
    }

    public var wrappedTitle: String {
        get {title ?? "Untitled"}
        set {title = newValue}
    }

    public var previewUIImage: UIImage? {
        guard
            let previewsDirectory = FileManager.default.previewsDirectory,
            let filename = self.imagePreview
        else { return nil }

        let filepath = previewsDirectory.appendingPathComponent(filename)

        do {
            let imageData = try Data(contentsOf: filepath)
            if let uiImage = UIImage(data: imageData) {
                return uiImage
            }
        } catch {
            Logger.main.notice("Error loading thumbnail image: \(error.localizedDescription)")
        }

        return nil
    }

    public var previewImage: Image? {
        if let previewUIImage = previewUIImage {
            return Image(uiImage: previewUIImage)
        }
        return nil
    }

    public var thumbnailImage: Image? {
        guard
            let thumbnailsDirectory = FileManager.default.thumbnailsDirectory,
            let filename = self.imageThumbnail
        else { return nil }

        let filepath = thumbnailsDirectory.appendingPathComponent(filename)

        do {
            let imageData = try Data(contentsOf: filepath)
            if let uiImage = UIImage(data: imageData) {
                return Image(uiImage: uiImage)
            }
        } catch {
            Logger.main.notice("Error loading thumbnail image: \(error.localizedDescription)")
        }

        return nil
    }

    static func create(moc managedObjectContext: NSManagedObjectContext, feedData: FeedData) -> Item {
        let item = Item.init(context: managedObjectContext)
        item.id = UUID()
        item.feedData = feedData

        return item
    }
}
