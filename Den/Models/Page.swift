//
//  Page.swift
//  Den
//
//  Created by Garrett Johnson on 5/18/20.
//  Copyright © 2020 Garrett Johnson. All rights reserved.
//

import SwiftUI
import CoreData


extension Page: Identifiable, Refreshable {
    public var feedArray: [Feed] {
        guard let feeds = feeds else {
            return []
        }
        
        return feeds.array as! [Feed]
    }
    
    public var wrappedName: String {
        get {name ?? "No Name"}
        set {name = newValue}
    }
    
    public var unreadCount: String {
        get {
            var count = 0
            feedArray.forEach { feed in
                count += feed.unreadItemCount
            }
            
            return String(count)
        }
    }
    
    static func create(in managedObjectContext: NSManagedObjectContext, workspace: Workspace) -> Page {
        let newPage = self.init(context: managedObjectContext)
        newPage.id = UUID()
        newPage.workspace = workspace
        newPage.name = "New Page"
        
        return newPage
    }
    
    func refresh() {
        print("Refreshing Page")
    }
}

extension Collection where Element == Page, Index == Int {
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
