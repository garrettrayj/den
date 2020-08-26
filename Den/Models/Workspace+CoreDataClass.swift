//
//  Workspace+CoreDataClass.swift
//  Den
//
//  Created by Garrett Johnson on 7/30/20.
//  Copyright © 2020 Garrett Johnson. All rights reserved.
//

import Foundation
import CoreData

@objc(Workspace)
public class Workspace: Refreshable, Identifiable {
    public var pagesArray: [Page] {
        get {
            guard let pages = pages else { return [] }
            return pages.sortedArray(using: [NSSortDescriptor(key: "userOrder", ascending: true)]) as! [Page]
        }
        set {
            pages = NSSet(array: newValue)
        }
    }
    
    var isEmpty: Bool {
        self.pagesArray.count == 0
    }
    
    static func create(in managedObjectContext: NSManagedObjectContext) -> Workspace {
        let workspace = self.init(context: managedObjectContext)
        workspace.id = UUID()
        
        return workspace
    }
    
    // MARK: Refreshable abstract properties and methods implementations
    
    override public var feedsArray: [Feed] {
        var feedAggregation: [Feed] = []
        pagesArray.forEach { page in
            feedAggregation += page.feedsArray
        }
        
        return feedAggregation
    }
    
    override func onRefreshComplete() {
        pagesArray.forEach { page in
            page.refreshed = Date()
            page.objectWillChange.send()
        }
        
        refreshed = Date()
        objectWillChange.send()
    }
}
