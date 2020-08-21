//
//  Page+CoreDataClass.swift
//  Den
//
//  Created by Garrett Johnson on 7/30/20.
//  Copyright © 2020 Garrett Johnson. All rights reserved.
//

import Foundation
import CoreData

@objc(Page)
public class Page: Refreshable, Identifiable {
    public var wrappedName: String {
        get {name ?? "No Name"}
        set {name = newValue}
    }
    
    public var unreadCount: Int {
        get {
            var count = 0
            feedsArray.forEach { feed in
                count += feed.unreadItemCount
            }
            return count
        }
    }
    
    static func create(in managedObjectContext: NSManagedObjectContext, workspace: Workspace) -> Page {
        let newPage = self.init(context: managedObjectContext)
        newPage.id = UUID()
        newPage.workspace = workspace
        newPage.name = "New Page"
        
        return newPage
    }
    
    // MARK: Refreshable abstract properties and methods implementations
    
    override public var feedsArray: [Feed] {
        
        get {
            guard let feeds = self.feeds else {
                return []
            }
            return feeds.array as! [Feed]
        }
        set {
            feeds = NSOrderedSet(array: newValue)
        }
    }
    
    override public var lastRefreshedLabel: String {
        if let refreshed = refreshed {
            let formatter = DateFormatter.create()
            return formatter.string(from: refreshed)
        }
        
        return "Page never updated"
    }
    
    override func onRefreshComplete() {
        refreshed = Date()
        objectWillChange.send()
    }
}
