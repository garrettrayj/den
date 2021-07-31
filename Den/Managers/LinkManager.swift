//
//  BrowserManager.swift
//  Den
//
//  Created by Garrett Johnson on 6/26/20.
//  Copyright © 2020 Garrett Johnson. All rights reserved.
//

import CoreData
import SafariServices

/**
 Opens links and logs history
 */
final class LinkManager: ObservableObject {
    public var controller: UIViewController?

    private var viewContext: NSManagedObjectContext
    private var crashManager: CrashManager
    private var profileManager: ProfileManager

    init(viewContext: NSManagedObjectContext, crashManager: CrashManager, profileManager: ProfileManager) {
        self.viewContext = viewContext
        self.crashManager = crashManager
        self.profileManager = profileManager
    }

    public func openLink(url: URL, logHistoryItem: Item? = nil, readerMode: Bool = false) {
        guard let controller = controller else {
            preconditionFailure("No controller present.")
        }

        if let historyItem = logHistoryItem {
            logHistory(item: historyItem)
        }

        let config = SFSafariViewController.Configuration()
        config.entersReaderIfAvailable = readerMode

        let safariViewController = SFSafariViewController(url: url, configuration: config)
        controller.modalPresentationStyle = .fullScreen
        controller.present(safariViewController, animated: true)
    }

    private func logHistory(item: Item) {
        guard let profile = profileManager.activeProfile else { return }

        let history = History.create(in: self.viewContext, profile: profile)
        history.link = item.link
        history.title = item.title
        history.visited = Date()

        do {
            try self.viewContext.save()

            // Update link color
            item.objectWillChange.send()

            // Update unread count in page navigation
            item.feedData?.feed?.page?.objectWillChange.send()
        } catch {
            self.crashManager.handleCriticalError(error as NSError)
        }
    }
}
