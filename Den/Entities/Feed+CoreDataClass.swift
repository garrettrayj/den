//
//  Feed+CoreDataClass.swift
//  Den
//
//  Created by Garrett Johnson on 7/30/20.
//  Copyright © 2020 Garrett Johnson. All rights reserved.
//

import Foundation
import CoreData
import FeedKit
import OSLog
import SwiftUI

@objc(Feed)
public class Feed: NSManagedObject {
    struct FeedIngestMeta {
        var thumbnails: [URL] = []
    }
    
    public var subscription: Subscription? {
        let values = value(forKey: "subscription") as? [Subscription]
        if let unwrappedValues = values {
            return unwrappedValues.first
        }
        
        return nil
    }
    
    public var itemsArray: [Item] {
        guard let items = items else {
            return []
        }
        
        return items.sortedArray(
            using: [NSSortDescriptor(key: "published", ascending: false)]
        ) as! [Item]
    }
    

    public var unreadItemCount: Int {
        itemsArray.filter { item in item.read == false }.count
    }
    
    public var itemsWithImageCount: Int {
        itemsArray.filter({ item in
            item.image != nil
        }).count
    }
    
    public var faviconImage: Image? {
        guard let localUrl = self.faviconLocal else { return nil }
        do {
            let imageData = try Data(contentsOf: localUrl)
            if let uiImage = UIImage(data: imageData) {
                return Image(uiImage: uiImage)
            }
        } catch {
            Logger.main.notice("Error loading favicon image: \(error.localizedDescription)")
        }
        
        return nil
    }
    
    static func create(in managedObjectContext: NSManagedObjectContext, subscriptionId: UUID) -> Feed {
        let newFeed = self.init(context: managedObjectContext)
        newFeed.id = UUID()
        newFeed.subscriptionId = subscriptionId
        
        return newFeed
    }
}

extension Collection where Element == Feed, Index == Int {
    func delete(at indices: IndexSet, from managedObjectContext: NSManagedObjectContext) {
        indices.forEach { managedObjectContext.delete(self[$0]) }
 
        do {
            try managedObjectContext.save()
        } catch {
            // Replace this implementation with code to handle the error appropriately.
            // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            let nserror = error as NSError
            fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
        }
    }
}
