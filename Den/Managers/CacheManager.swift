//
//  CacheManager.swift
//  Den
//
//  Created by Garrett Johnson on 8/8/20.
//  Copyright © 2020 Garrett Johnson. All rights reserved.
//

import Foundation
import CoreData
import URLImage

class CacheManager: ObservableObject {
    @Published var clearing: Bool = false
    
    private var workspace: Workspace
    private var viewContext: NSManagedObjectContext
    private var managedObjectContext: NSManagedObjectContext
    
    init(workspace: Workspace, viewContext: NSManagedObjectContext) {
        self.workspace = workspace
        self.viewContext = viewContext
        
        managedObjectContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        managedObjectContext.parent = viewContext
        managedObjectContext.undoManager = nil
    }
    
    func clear() {
        if clearing {
            print("Already clearing cache")
            return
        } else {
            clearing = true
        }
        
        
        /// 1. [Reset image cache](https://github.com/dmytro-anokhin/url-image#maintaining-local-cache)
        URLImageService.shared.resetFileCache()
        
        /// 2. Delete feed items
        managedObjectContext.perform {
            autoreleasepool {
                let feedObjectIDs: [NSManagedObjectID] = self.workspace.feedsArray.map { feed in feed.objectID }
                for feedObjectID in feedObjectIDs {
                    let feed = self.managedObjectContext.object(with: feedObjectID) as! Feed
                    for item in feed.itemsArray {
                        self.managedObjectContext.delete(item)
                    }
                    feed.favicon = nil
                    feed.refreshed = nil
                }
            }
            
            do {
                try self.managedObjectContext.save()
                self.viewContext.performAndWait {
                    do {
                        try self.viewContext.save()
                        
                        for page in self.workspace.pagesArray {
                            page.objectWillChange.send()
                        }
                    } catch {
                        fatalError("Failure to save view context: \(error)")
                    }
                }
            } catch {
                fatalError("Failure to save private context: \(error)")
            }
        }
        
        /// 3. Clear URLCache
        URLCache.shared.removeAllCachedResponses()
        
        clearing = false
    }
}
