//
//  PagesViewModel.swift
//  Den
//
//  Created by Garrett Johnson on 8/28/21.
//  Copyright © 2021 Garrett Johnson. All rights reserved.
//

import CoreData

final class PagesViewModel: ObservableObject {
    @Published var pageViewModels: [PageViewModel]

    private var profileManager: ProfileManager
    private var viewContext: NSManagedObjectContext
    private var crashManager: CrashManager

    init(
        profileManager: ProfileManager,
        viewContext: NSManagedObjectContext,
        crashManager: CrashManager,
        refreshManager: RefreshManager
    ) {
        self.profileManager = profileManager
        self.viewContext = viewContext
        self.crashManager = crashManager

        self.pageViewModels = profileManager.activeProfile.pagesArray.map({ page in
            PageViewModel(page: page, refreshManager: refreshManager)
        })
    }

    func refreshAll() {
        pageViewModels.forEach { pageViewModel in
            pageViewModel.refresh()
        }
    }

    func createPage() {
        _ = Page.create(in: viewContext, profile: profileManager.activeProfile)
        do {
            try viewContext.save()
            profileManager.objectWillChange.send()
        } catch let error as NSError {
            crashManager.handleCriticalError(error)
        }

    }

    func movePage( from source: IndexSet, to destination: Int) {
        var revisedItems = profileManager.activeProfile.pagesArray

        // change the order of the items in the array
        revisedItems.move(fromOffsets: source, toOffset: destination)

        // update the userOrder attribute in revisedItems to
        // persist the new order. This is done in reverse order
        // to minimize changes to the indices.
        for reverseIndex in stride(from: revisedItems.count - 1, through: 0, by: -1 ) {
            revisedItems[reverseIndex].userOrder = Int16(reverseIndex)
        }

        if viewContext.hasChanges {
            do {
                try viewContext.save()
            } catch let error as NSError {
                crashManager.handleCriticalError(error)
            }
        }
    }

    func deletePage(indices: IndexSet) {
        profileManager.activeProfile.pagesArray.delete(at: indices, from: viewContext)
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
            let page = Page.create(in: self.viewContext, profile: profileManager.activeProfile)
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
        } catch let error as NSError {
            crashManager.handleCriticalError(error)
        }

        profileManager.objectWillChange.send()
    }
}
