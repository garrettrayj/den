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

    public var thumbnailImage: Image? {
        guard
            let thumbnailsDirectory = FileManager.default.thumbnailsDirectory,
            let filename = self.imageFile
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

extension Collection where Element == Item, Index == Int {
    func delete(at indices: IndexSet, from managedObjectContext: NSManagedObjectContext) {
        indices.forEach { managedObjectContext.delete(self[$0]) }

        do {
            try managedObjectContext.save()
        } catch {
            // Replace this implementation with code to handle the error appropriately.
            // fatalError() causes the application to generate a crash log and terminate.
            // You should not use this function in a shipping application,
            // although it may be useful during development.
            let nserror = error as NSError
            fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
        }
    }
}
