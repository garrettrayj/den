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
class LinkManager: ObservableObject {
    public var controller: UIViewController?
    
    private var viewContext: NSManagedObjectContext
    private var crashManager: CrashManager
    private var mainViewModel: MainViewModel
    
    init(viewContext: NSManagedObjectContext, crashManager: CrashManager, mainViewModel: MainViewModel) {
        self.viewContext = viewContext
        self.crashManager = crashManager
        self.mainViewModel = mainViewModel
    }
    
    public func openLink(url:URL, logHistoryItem: Item? = nil, readerMode: Bool = false) {
        guard let controller = controller else {
            preconditionFailure("No controller present.")
        }
        
        if let historyItem = logHistoryItem {
            logHistory(item: historyItem)
        }
        
        let config = SFSafariViewController.Configuration()
        config.entersReaderIfAvailable = readerMode
        
        let vc = SFSafariViewController(url: url, configuration: config)
        controller.modalPresentationStyle = .fullScreen
        controller.present(vc, animated: true)
    }
    
    public func logHistory(item: Item) {
        guard let profile = mainViewModel.activeProfile else { return }
        
        let history = History.create(in: self.viewContext, profile: profile)
        history.link = item.link
        history.title = item.title
        history.visited = Date()
        
        if self.viewContext.hasChanges {
            do {
                try self.viewContext.save()
                
                // Update link color
                item.objectWillChange.send()
                
                // Update unread count in page navigation
                item.feedData?.feed?.page?.objectWillChange.send()
            } catch {
                DispatchQueue.main.async {
                    self.crashManager.handleCriticalError(error as NSError)
                }
            }
        }
    }
}
