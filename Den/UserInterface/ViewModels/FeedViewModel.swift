//
//  FeedViewModel.swift
//  Den
//
//  Created by Garrett Johnson on 11/28/21.
//  Copyright © 2021 Garrett Johnson. All rights reserved.
//

import Combine
import CoreData
import SwiftUI

final class FeedViewModel: ObservableObject {
    let viewContext: NSManagedObjectContext
    let crashManager: CrashManager

    private var queuedSubscriber: AnyCancellable?
    private var refreshedSubscriber: AnyCancellable?

    @Published var feed: Feed
    @Published var refreshing: Bool

    init(viewContext: NSManagedObjectContext, crashManager: CrashManager, feed: Feed, refreshing: Bool) {
        self.viewContext = viewContext
        self.crashManager = crashManager
        self.feed = feed
        self.refreshing = refreshing

        self.queuedSubscriber = NotificationCenter.default
            .publisher(for: .feedQueued, object: feed.objectID)
            .receive(on: RunLoop.main)
            .map { _ in true }
            .assign(to: \.refreshing, on: self)

        self.refreshedSubscriber = NotificationCenter.default
            .publisher(for: .feedRefreshed, object: feed.objectID)
            .receive(on: RunLoop.main)
            .map { _ in false }
            .assign(to: \.refreshing, on: self)
    }

    deinit {
        queuedSubscriber?.cancel()
        refreshedSubscriber?.cancel()
    }

    func save() {
        if viewContext.hasChanges {
            do {
                try viewContext.save()
                feed.feedData?.itemsArray.forEach { item in
                    item.objectWillChange.send()
                }
                NotificationCenter.default.post(name: .feedRefreshed, object: feed.objectID)
            } catch let error as NSError {
                crashManager.handleCriticalError(error)
            }
        }
    }

    func delete() {
        guard let pageObjectID = feed.page?.objectID else { return }

        viewContext.delete(feed)
        save()

        NotificationCenter.default.post(name: .pageRefreshed, object: pageObjectID)
    }

    func copyUrl() {
        let pasteboard = UIPasteboard.general
        pasteboard.string = feed.url!.absoluteString
    }
}

extension FeedViewModel: Identifiable {
    var id: Feed {
        feed
    }
}

extension FeedViewModel: Equatable {
    static func == (lhs: FeedViewModel, rhs: FeedViewModel) -> Bool {
        lhs.feed == rhs.feed
    }
}

extension FeedViewModel: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(feed)
    }
}
