//
//  PagesViewModel.swift
//  Den
//
//  Created by Garrett Johnson on 8/28/21.
//  Copyright © 2021 Garrett Johnson. All rights reserved.
//

import CoreData
import OSLog
import SafariServices
import SwiftUI

final class ContentViewModel: ObservableObject {
    @Published var activeNav: String?
    @Published var pageViewModels: [PageViewModel] = []

    let queue = OperationQueue()

    private var viewContext: NSManagedObjectContext
    private var crashManager: CrashManager
    private var refreshManager: RefreshManager
    private var profileManager: ProfileManager

    public var hostingWindow: UIWindow?
    public var searchViewModel: SearchViewModel!

    init(
        viewContext: NSManagedObjectContext,
        crashManager: CrashManager,
        refreshManager: RefreshManager,
        profileManager: ProfileManager
    ) {
        self.viewContext = viewContext

        self.crashManager = crashManager
        self.refreshManager = refreshManager
        self.profileManager = profileManager

        self.pageViewModels = profileManager.activeProfile?.pagesArray.map({ page in
            PageViewModel(page: page, viewContext: viewContext, crashManager: crashManager)
        }) ?? []
    }

    func refreshAll() {
        refreshManager.refresh(contentViewModel: self)
    }

    func createPage() {
        guard let activeProfile = profileManager.activeProfile else {
            return
        }

        let page = Page.create(in: viewContext, profile: activeProfile)
        do {
            try viewContext.save()
            self.pageViewModels.append(PageViewModel(
                page: page,
                viewContext: viewContext,
                crashManager: crashManager
            ))
        } catch let error as NSError {
            crashManager.handleCriticalError(error)
        }
    }

    func movePage( from source: IndexSet, to destination: Int) {
        guard let activeProfile = profileManager.activeProfile else {
            return
        }

        var revisedItems = activeProfile.pagesArray

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
                pageViewModels.sort { aViewModel, bViewModel in
                    aViewModel.page.userOrder < bViewModel.page.userOrder
                }
            } catch let error as NSError {
                crashManager.handleCriticalError(error)
            }
        }
    }

    func deletePage(indices: IndexSet) {
        guard let activeProfile = profileManager.activeProfile else {
            return
        }

        indices.forEach {
            let page = activeProfile.pagesArray[$0]
            viewContext.delete(page)
            pageViewModels.remove(at: $0)
        }

        if viewContext.hasChanges {
            do {
                try viewContext.save()
            } catch let error as NSError {
                crashManager.handleCriticalError(error)
            }
        }
    }

    func loadDemo() {
        guard let demoPath = Bundle.main.path(forResource: "Demo", ofType: "opml") else {
            preconditionFailure("Missing demo feeds source file")
        }

        guard let activeProfile = profileManager.activeProfile else {
            return
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
            let page = Page.create(in: self.viewContext, profile: activeProfile)
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
            newPages.forEach { page in
                self.pageViewModels.append(PageViewModel(
                    page: page,
                    viewContext: viewContext,
                    crashManager: crashManager
                ))
            }
        } catch let error as NSError {
            crashManager.handleCriticalError(error)
        }
    }

    func showSearch() {
        if activeNav != "search" {
            activeNav = "search"
        }
    }
}
