//
//  Workspace.swift
//  Den
//
//  Created by Garrett Johnson on 5/30/20.
//  Copyright © 2020 Garrett Johnson. All rights reserved.
//

import CoreData

extension Workspace: Identifiable, Refreshable {
    var isLoading: Bool {
        set {
            self.loading = newValue
            if newValue == true {
                load()
            }
        }
        get {
            return loading
        }
    }
    
    public var pageArray: [Page] {
        guard let pages = pages else {
            return []
        }
        
        return pages.array as! [Page]
    }
    
    public var feedArray: [Feed] {
        var feeds: [Feed] = []
        pageArray.forEach { page in
            feeds.append(contentsOf: page.feedArray)
        }
        return feeds
    }
    
    static func create(in managedObjectContext: NSManagedObjectContext) -> Workspace {
        let workspace = self.init(context: managedObjectContext)
        workspace.id = UUID()
        
        return workspace
    }
    
    func load() {
        DispatchQueue.global(qos: .userInteractive).async {
            var feedsForUpdate: Array<Feed> = []
            self.pageArray.forEach { page in
                page.feedArray.forEach { feed in
                    feedsForUpdate.append(feed)
                }
            }
            
            //let feedUpdater = UpdateCoor(feeds: feedsForUpdate)
            //feedUpdater.start()
            
            self.isLoading = false
        }
    }
}


// MARK: Collection Extensions

extension Collection where Element == Workspace, Index == Int {
    func delete(at indices: IndexSet, from managedObjectContext: NSManagedObjectContext) {
        indices.forEach { managedObjectContext.delete(self[$0]) }
 
        do {
            try managedObjectContext.save()
        } catch {
            let nserror = error as NSError
            fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
        }
    }
}
