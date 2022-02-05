//
//  PageViewModel.swift
//  Den
//
//  Created by Garrett Johnson on 11/28/21.
//  Copyright © 2021 Garrett Johnson. All rights reserved.
//

import Combine
import CoreData
import SwiftUI

class PageViewModel: ObservableObject {
    let viewContext: NSManagedObjectContext
    let crashManager: CrashManager

    private var queuedSubscriber: AnyCancellable?
    private var refreshedSubscriber: AnyCancellable?

    @Published var page: Page
    @Published var refreshing: Bool

    var feedViewModels: [FeedViewModel] {
        page.feedsArray.compactMap { feed in
            FeedViewModel(
                viewContext: viewContext,
                crashManager: crashManager,
                feed: feed,
                refreshing: refreshing
            )
        }
    }

    init(viewContext: NSManagedObjectContext, crashManager: CrashManager, page: Page, refreshing: Bool) {
        self.viewContext = viewContext
        self.crashManager = crashManager
        self.page = page
        self.refreshing = refreshing

        self.queuedSubscriber = NotificationCenter.default
            .publisher(for: .pageQueued, object: page.objectID)
            .receive(on: RunLoop.main)
            .map { _ in true }
            .assign(to: \.refreshing, on: self)

        self.refreshedSubscriber = NotificationCenter.default
            .publisher(for: .pageRefreshed, object: page.objectID)
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
            } catch {
                crashManager.handleCriticalError(error as NSError)
            }
        }
    }

    func deleteFeed(indices: IndexSet) {
        indices.forEach { viewContext.delete(page.feedsArray[$0]) }

        do {
            try viewContext.save()
            NotificationCenter.default.post(name: .pageRefreshed, object: page.objectID)
        } catch {
            crashManager.handleCriticalError(error as NSError)
        }
    }

    func moveFeed( from source: IndexSet, to destination: Int) {
        // Make an array of items from fetched results
        var revisedItems: [Feed] = page.feedsArray.map { $0 }

        // change the order of the items in the array
        revisedItems.move(fromOffsets: source, toOffset: destination)

        // update the userOrder attribute in revisedItems to
        // persist the new order. This is done in reverse order
        // to minimize changes to the indices.
        for reverseIndex in stride(from: revisedItems.count - 1, through: 0, by: -1 ) {
            revisedItems[reverseIndex].userOrder = Int16(reverseIndex)
        }
    }
}

extension PageViewModel: Identifiable {
    var id: Page {
        page
    }
}

extension PageViewModel: Equatable {
    static func == (lhs: PageViewModel, rhs: PageViewModel) -> Bool {
        lhs.page == rhs.page
    }
}

extension PageViewModel: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(page)
    }
}
