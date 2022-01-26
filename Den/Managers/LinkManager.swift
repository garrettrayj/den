//
//  LinkManager.swift
//  Den
//
//  Created by Garrett Johnson on 11/12/21.
//  Copyright © 2021 Garrett Johnson. All rights reserved.
//

import CoreData
import SwiftUI
import SafariServices

final class LinkManager: ObservableObject {
    // Hosting window set in app lifecycle
    public var hostingWindow: UIWindow?

    private var viewContext: NSManagedObjectContext
    private var crashManager: CrashManager
    private var profileManager: ProfileManager

    init(
        viewContext: NSManagedObjectContext,
        crashManager: CrashManager,
        profileManager: ProfileManager
    ) {
        self.viewContext = viewContext
        self.crashManager = crashManager
        self.profileManager = profileManager
    }

    public func openLink(url: URL?, logHistoryItem: Item? = nil, readerMode: Bool = false) {
        guard let url = url else { return }

        if let historyItem = logHistoryItem {
            logHistory(item: historyItem)
        }

        let config = SFSafariViewController.Configuration()
        config.entersReaderIfAvailable = readerMode

        let safariViewController = SFSafariViewController(url: url, configuration: config)

        guard let rootViewController = hostingWindow?.rootViewController else { return }
        rootViewController.modalPresentationStyle = .fullScreen
        rootViewController.present(safariViewController, animated: true)
    }

    private func logHistory(item: Item) {
        guard let activeProfile = profileManager.activeProfile else {
            return
        }

        let history = History.create(in: viewContext, profile: activeProfile)
        history.link = item.link
        history.title = item.title
        history.visited = Date()

        do {
            try viewContext.save()

            // Update link color
            item.objectWillChange.send()

            // Update unread count in page navigation
            item.feedData?.feed?.page?.objectWillChange.send()
        } catch {
            crashManager.handleCriticalError(error as NSError)
        }
    }
}
