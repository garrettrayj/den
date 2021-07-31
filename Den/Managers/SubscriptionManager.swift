//
//  ScreenManager.swift
//  Den
//
//  Created by Garrett Johnson on 9/5/20.
//  Copyright © 2020 Garrett Johnson. All rights reserved.
//

import CoreData

final class SubscriptionManager: ObservableObject {
    @Published var destinationPage: Page?
    @Published var showingAddSubscription: Bool = false
    @Published var subscribeURLString: String = ""

    private var viewContext: NSManagedObjectContext
    private var profileManager: ProfileManager
    private var crashManager: CrashManager

    init(viewContext: NSManagedObjectContext, profileManager: ProfileManager, crashManager: CrashManager) {
        self.viewContext = viewContext
        self.profileManager = profileManager
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

    func loadDemo() {
        guard let demoPath = Bundle.main.path(forResource: "DemoWorkspace", ofType: "opml") else {
            preconditionFailure("Missing demo feeds source file")
        }

        let opmlReader = OPMLReader(xmlURL: URL(fileURLWithPath: demoPath))

        var newPages: [Page] = []
        opmlReader.outlineFolders.forEach { opmlFolder in
            let page = Page.create(in: self.viewContext, profile: profileManager.activeProfile!)
            page.name = opmlFolder.name
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
