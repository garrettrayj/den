//
//  SidebarViewModel.swift
//  Den
//
//  Created by Garrett Johnson on 11/28/21.
//  Copyright © 2021 Garrett Johnson. All rights reserved.
//

import Combine
import Foundation
import CoreData
import SwiftUI

final class SidebarViewModel: ObservableObject {
    let viewContext: NSManagedObjectContext
    let crashManager: CrashManager

    @Published var profile: Profile
    @Published var refreshing: Bool = false

    var refreshProgress: Progress = Progress()

    private var queuedSubscriber: AnyCancellable?
    private var refreshedSubscriber: AnyCancellable?
    private var feedRefreshedSubscriber: AnyCancellable?

    init(viewContext: NSManagedObjectContext, crashManager: CrashManager, profile: Profile) {
        self.viewContext = viewContext
        self.crashManager = crashManager
        self.profile = profile

        self.queuedSubscriber = NotificationCenter.default
            .publisher(for: .profileQueued, object: profile.objectID)
            .receive(on: RunLoop.main)
            .map { _ in
                self.refreshProgress.totalUnitCount = Int64(profile.feedCount)
                self.refreshProgress.completedUnitCount = 0

                return true
            }
            .assign(to: \.refreshing, on: self)

        self.refreshedSubscriber = NotificationCenter.default
            .publisher(for: .profileRefreshed, object: profile.objectID)
            .receive(on: RunLoop.main)
            .map { _ in false }
            .assign(to: \.refreshing, on: self)

        self.feedRefreshedSubscriber = NotificationCenter.default
            .publisher(for: .feedRefreshed)
            .receive(on: RunLoop.main)
            .sink { _ in
                self.refreshProgress.completedUnitCount += 1
            }
    }

    func save() {
        if viewContext.hasChanges {
            do {
                try viewContext.save()
                self.objectWillChange.send()
            } catch {
                crashManager.handleCriticalError(error as NSError)
            }
        }
    }

    func createPage() {
        _ = Page.create(in: viewContext, profile: profile)

        save()
    }

    func movePage( from source: IndexSet, to destination: Int) {
        var revisedItems = profile.pagesArray

        // change the order of the items in the array
        revisedItems.move(fromOffsets: source, toOffset: destination)

        // update the userOrder attribute in revisedItems to
        // persist the new order. This is done in reverse order
        // to minimize changes to the indices.
        for reverseIndex in stride(from: revisedItems.count - 1, through: 0, by: -1 ) {
            revisedItems[reverseIndex].userOrder = Int16(reverseIndex)
        }

        // Move may be called without tapping the edit button, so the result is saved immediately
        save()
    }

    func deletePage(indices: IndexSet) {
        indices.forEach {
            let objectID = profile.pagesArray[$0].objectID
            viewContext.delete(profile.pagesArray[$0])
            NotificationCenter.default.post(name: .pageRefreshed, object: objectID)
        }

        // Delete may be called without tapping the edit button, so the result is saved immediately
        save()
    }

    func loadDemo() {
        guard let demoPath = Bundle.main.path(forResource: "Demo", ofType: "opml") else {
            preconditionFailure("Missing demo feeds source file")
        }

        let symbolMap = [
            "World News": "globe",
            "US News": "newspaper",
            "Technology": "cpu",
            "Business": "briefcase",
            "Science": "atom",
            "Space": "sparkles",
            "Funnies": "face.smiling",
            "Curiosity": "person.and.arrow.left.and.arrow.right",
            "Gaming": "gamecontroller",
            "Entertainment": "film"
        ]

        let opmlReader = OPMLReader(xmlURL: URL(fileURLWithPath: demoPath))

        var newPages: [Page] = []
        opmlReader.outlineFolders.forEach { opmlFolder in
            let page = Page.create(in: self.viewContext, profile: profile)
            page.name = opmlFolder.name
            page.symbol = symbolMap[opmlFolder.name]
            newPages.append(page)

            opmlFolder.feeds.forEach { opmlFeed in
                let feed = Feed.create(in: self.viewContext, page: page, url: opmlFeed.url)
                feed.title = opmlFeed.title
            }
        }

        do {
            try viewContext.save()
            self.objectWillChange.send()
        } catch let error as NSError {
            crashManager.handleCriticalError(error)
        }
    }

    deinit {
        queuedSubscriber?.cancel()
        refreshedSubscriber?.cancel()
    }
}
