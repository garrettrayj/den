//
//  BrowserManager.swift
//  Den
//
//  Created by Garrett Johnson on 6/26/20.
//  Copyright © 2020 Garrett Johnson. All rights reserved.
//

import Foundation
import SwiftUI
import SafariServices
import CoreData

/**
 Class for providing functionality not quite reachable with SwiftUI
 (such as opening SFSafariViewController full screen)
 */
class BrowserManager: ObservableObject {
    public var controller: UIViewController?
    
    private var viewContext: NSManagedObjectContext
    private var crashManager: CrashManager
    
    init(persistenceManager: PersistenceManager, crashManager: CrashManager) {
        self.viewContext = persistenceManager.container.viewContext
        self.crashManager = crashManager
        
    }
    
    func openSafari(url:URL, readerMode: Bool = false) {
        guard let controller = controller else {
            preconditionFailure("No controller present.")
        }
        
        let config = SFSafariViewController.Configuration()
        config.entersReaderIfAvailable = readerMode
        
        let vc = SFSafariViewController(url: url, configuration: config)
        
        controller.modalPresentationStyle = .fullScreen
        controller.present(vc, animated: true)
    }
    
    func logVisit(item: Item) {
        let visit = Visit.create(in: self.viewContext)
        visit.link = item.link
        visit.title = item.title
        visit.visited = Date()
        
        if self.viewContext.hasChanges {
            do {
                try self.viewContext.save()
                item.objectWillChange.send()
            } catch {
                DispatchQueue.main.async {
                    self.crashManager.handleCriticalError(error as NSError)
                }
            }
        }
    }
}
