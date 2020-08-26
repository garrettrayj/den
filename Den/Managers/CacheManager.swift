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
    
    private var persistentContainer: NSPersistentContainer
    
    init(persistentContainer: NSPersistentContainer) {
        self.persistentContainer = persistentContainer
    }
    
    func clearAll(workspace: Workspace) {
        clearWorkspaceItems(workspace: workspace)
        clearWebCaches()
    }
    
    func clearWebCaches() {
        URLCache.shared.removeAllCachedResponses()
        URLImageService.shared.resetFileCache()
    }
    
    func clearWorkspaceItems(workspace: Workspace) {
        let context: NSManagedObjectContext = self.persistentContainer.newBackgroundContext()
        context.performAndWait {
            workspace.feedsArray.forEach { feed in
                feed.itemsArray.forEach { item in
                    context.delete(context.object(with: item.objectID))
                }
            }
            
            if context.hasChanges {
                do {
                    try context.save()
                } catch {
                    fatalError("Unable to save backbround context: \(error)")
                }
            }
        }
    }
}
