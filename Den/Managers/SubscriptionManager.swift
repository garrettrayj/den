//
//  ScreenManager.swift
//  Den
//
//  Created by Garrett Johnson on 9/5/20.
//  Copyright © 2020 Garrett Johnson. All rights reserved.
//

import CoreData
import SwiftUI

final class SubscriptionManager: ObservableObject {
    @Published var destinationPage: Page?
    @Published var showingAddSubscription: Bool = false
    @Published var subscribeURLString: String = ""

    private var viewContext: NSManagedObjectContext
    private var profileManager: ProfileManager
    private var refreshManager: RefreshManager
    private var crashManager: CrashManager

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
        "TV & Movies": "film",
        "Music": "music.note"
    ]

    init(
        viewContext: NSManagedObjectContext,
        profileManager: ProfileManager,
        refreshManager: RefreshManager,
        crashManager: CrashManager
    ) {
        self.viewContext = viewContext
        self.profileManager = profileManager
        self.refreshManager = refreshManager
        self.crashManager = crashManager
    }

    func showAddSubscription(to url: URL? = nil) {
        if
            let url = url,
            var urlComponents = URLComponents(string: url.absoluteString.replacingOccurrences(of: "feed:", with: ""))
        {
            if urlComponents.scheme == nil {
                urlComponents.scheme = "http"
            }

            if let urlString = urlComponents.string {
                subscribeURLString = urlString
            }
        }

        self.showingAddSubscription = true
    }

    func reset() {
        showingAddSubscription = false
        subscribeURLString = ""
    }

    func createFeed(url: URL) -> Feed? {
        guard let destinationPage = destinationPage else { return nil }

        let feed = Feed.create(in: self.viewContext, page: destinationPage, prepend: true)
        feed.url = url

        return feed
    }

    func loadDemo() {
        guard let demoPath = Bundle.main.path(forResource: "DemoWorkspace", ofType: "opml") else {
            preconditionFailure("Missing demo feeds source file")
        }

        guard let profile = profileManager.activeProfile else { return }

        let opmlReader = OPMLReader(xmlURL: URL(fileURLWithPath: demoPath))

        var newPages: [Page] = []
        opmlReader.outlineFolders.forEach { opmlFolder in
            let page = Page.create(in: self.viewContext, profile: profile)
            page.name = opmlFolder.name
            page.symbol = symbolMap[opmlFolder.name]
            newPages.append(page)

            opmlFolder.feeds.forEach { opmlFeed in
                let feed = Feed.create(in: self.viewContext, page: page)
                feed.title = opmlFeed.title
                feed.url = opmlFeed.url
            }
        }

        do {
            try viewContext.save()
            profileManager.objectWillChange.send()
        } catch let error as NSError {
            crashManager.handleCriticalError(error)
        }
    }
}
