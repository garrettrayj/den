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

@objc(Feed)
public class Feed: Refreshable {
    public var itemsArray: [Item] {
        guard let items = items else {
            return []
        }
        
        return items.sortedArray(
            using: [NSSortDescriptor(key: "published", ascending: false)]
        ) as! [Item]
    }
    
    public var urlString: String {
        get{url?.absoluteString ?? ""}
        set{url = URL(string: newValue)}
    }
    
    public var wrappedTitle: String {
        get{title ?? "Untitled"}
        set{title = newValue}
    }
    
    public var unreadItemCount: Int {
        itemsArray.prefix(Int(itemLimit)).filter({ item in
            item.read == false
        }).count
    }
    
    public var itemsWithImageCount: Int {
        itemsArray.filter({ item in
            item.image != nil
        }).count
    }
    
    // MARK: Refreshable abstract properties and methods implementations
    
    override public var feedsArray: [Feed] {
        return [self]
    }
    
    override public var lastRefreshedLabel: String {
        if let refreshed = refreshed {
            let formatter = DateFormatter.create()
            return formatter.string(from: refreshed)
        }
        
        return "Feed never updated"
    }
    
    override func onRefreshComplete() {
        page?.objectWillChange.send()
        refreshed = Date()
    }
    
    static func create(in managedObjectContext: NSManagedObjectContext, page: Page?) -> Feed {
        let newFeed = self.init(context: managedObjectContext)
        newFeed.id = UUID()
        newFeed.itemLimit = 5
        newFeed.showLargePreviews = false
        newFeed.showThumbnails = true
        newFeed.page = page
        
        return newFeed
    }
}

extension Feed: Identifiable {
    
}
