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
            feedsArray.reduce(0) { (result, feed) -> Int in
                result + feed.unreadItemCount
            }
        }
    }
    
    static func create(in managedObjectContext: NSManagedObjectContext, workspace: Workspace) -> Page {
        let newPage = self.init(context: managedObjectContext)
        newPage.id = UUID()
        newPage.workspace = workspace
        newPage.userOrder = Int16(workspace.pages?.count ?? 0 + 1)
        newPage.name = "New Page"
        
        return newPage
    }
    
    // MARK: Refreshable abstract properties and methods implementations
    
    override public var lastRefreshed: Date? {
        return refreshed
    }
    
    override public var feedsArray: [Feed] {
        get {
            guard let feeds = self.feeds else { return [] }
            return feeds.sortedArray(using: [NSSortDescriptor(key: "userOrder", ascending: true)]) as! [Feed]
        }
        set {
            feeds = NSSet(array: newValue)
        }
    }
    
    override func onRefreshComplete() {
        refreshed = Date()
        objectWillChange.send()
    }
}
