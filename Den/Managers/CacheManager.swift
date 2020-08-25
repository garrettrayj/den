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
    
    private var parentContext: NSManagedObjectContext
    private var privateContext: NSManagedObjectContext
    
    init(parentContext: NSManagedObjectContext) {
        self.parentContext = parentContext
        
        privateContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        privateContext.parent = parentContext
        privateContext.undoManager = nil
    }
    
    func clear(workspace: Workspace) {
        if clearing {
            print("Already clearing cache")
            return
        } else {
            clearing = true
        }
        
        /// 1. [Reset image cache](https://github.com/dmytro-anokhin/url-image#maintaining-local-cache)
        URLImageService.shared.resetFileCache()
        
        /// 2. Delete feed items
        privateContext.perform {
            autoreleasepool {
                let feedObjectIDs: [NSManagedObjectID] = workspace.feedsArray.map { feed in feed.objectID }
                for feedObjectID in feedObjectIDs {
                    let feed = self.privateContext.object(with: feedObjectID) as! Feed
                    for item in feed.itemsArray {
                        self.privateContext.delete(item)
                    }
                    feed.favicon = nil
                    feed.refreshed = nil
                }
            }
            
            if self.privateContext.hasChanges {
                do {
                    try self.privateContext.save()
                    self.parentContext.performAndWait {
                        do {
                            try self.parentContext.save()
                            
                            for page in workspace.pagesArray {
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
        }
        
        /// 3. Clear URLCache
        URLCache.shared.removeAllCachedResponses()
        
        clearing = false
    }
}
