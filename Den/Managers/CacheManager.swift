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
    
    func clearAll() {
        clearItems()
        clearWebCaches()
    }
    
    func clearWebCaches() {
        URLCache.shared.removeAllCachedResponses()
        URLImageService.shared.resetFileCache()
    }
    
    func clearItems() {
        // TODO: Clear items
    }
}
