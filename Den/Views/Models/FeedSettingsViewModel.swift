//
//  FeedSettingsViewModel.swift
//  Den
//
//  Created by Garrett Johnson on 11/11/21.
//  Copyright © 2021 Garrett Johnson. All rights reserved.
//

import SwiftUI

final class FeedSettingsViewModel: ObservableObject {
    @Published var feed: Feed
    @Published var showingDeleteAlert = false

    private var viewContext: NSManagedObjectContext
    private var crashManager: CrashManager

    init(feed: Feed, viewContext: NSManagedObjectContext, crashManager: CrashManager) {
        self.feed = feed
        self.viewContext = viewContext
        self.crashManager = crashManager
    }

    func openWebsite() {
        if let url = feed.feedData?.link {
            UIApplication.shared.open(url)
        }
    }

    func save() {
        if viewContext.hasChanges {
            do {
                try viewContext.save()
            } catch let error as NSError {
                crashManager.handleCriticalError(error)
            }
        }
    }

    func delete() {
        viewContext.delete(feed)
    }

    func copyUrl() {
        let pasteboard = UIPasteboard.general
        pasteboard.string = feed.url!.absoluteString
    }
}
