//
//  FeedSettingsViewModel.swift
//  Den
//
//  Created by Garrett Johnson on 2/16/22.
//  Copyright © 2022 Garrett Johnson. All rights reserved.
//

import Combine
import CoreData
import SwiftUI

final class FeedSettingsViewModel: ObservableObject {
    let viewContext: NSManagedObjectContext
    let crashManager: CrashManager

    @Published var feed: Feed
    @Published var showingDeleteAlert = false

    init(viewContext: NSManagedObjectContext, crashManager: CrashManager, feed: Feed) {
        self.viewContext = viewContext
        self.crashManager = crashManager
        self.feed = feed
    }

    func save() {
        if viewContext.hasChanges {
            do {
                try viewContext.save()
                feed.feedData?.itemsArray.forEach { item in
                    item.objectWillChange.send()
                }
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
