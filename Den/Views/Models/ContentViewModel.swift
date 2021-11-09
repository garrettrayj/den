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
    @Published var activeProfile: Profile?
    @Published var activeNav: String?
    @Published var pageViewModels: [PageViewModel] = []
    @Published var showingCrashMessage: Bool = false
    @Published var currentPageId: String?
    @Published var showingAddSubscription: Bool = false
    @Published var openedUrlString: String = ""

    let queue = OperationQueue()

    private var persistenceManager: PersistenceManager
    private var persistentContainer: NSPersistentContainer
    private var viewContext: NSManagedObjectContext

    public var hostingWindow: UIWindow?
    public var searchViewModel: SearchViewModel!
    public var subscribeViewModel: SubscribeViewModel!
    public var historyViewModel: HistoryViewModel!

    init(persistenceManager: PersistenceManager) {
        self.persistenceManager = persistenceManager
        self.persistentContainer = persistenceManager.container
        self.viewContext = persistenceManager.container.viewContext

        if CommandLine.arguments.contains("--reset") {
            resetProfiles()
        } else {
            loadProfiles()
        }

        self.pageViewModels = activeProfile?.pagesArray.map({ page in
            PageViewModel(page: page, contentViewModel: self)
        }) ?? []

        self.searchViewModel = SearchViewModel(
            viewContext: viewContext,
            contentViewModel: self
        )

        self.subscribeViewModel = SubscribeViewModel(
            viewContext: viewContext,
            contentViewModel: self
        )

        self.historyViewModel = HistoryViewModel(
            viewContext: viewContext,
            contentViewModel: self
        )

        self.queue.maxConcurrentOperationCount = 10
    }

    func applyUIStyle() {
        let uiStyle = UIUserInterfaceStyle.init(rawValue: UserDefaults.standard.integer(forKey: "UIStyle"))!
        hostingWindow?.overrideUserInterfaceStyle = uiStyle
    }

    public func handleCriticalError(_ anError: NSError) {
        Logger.main.critical("\(self.formatErrorMessage(anError))")
        showingCrashMessage = true
    }

    func refreshAll() {
        self.pageViewModels.forEach { pageViewModel in
            pageViewModel.refresh()
        }
    }

    func createPage() {
        guard let activeProfile = activeProfile else {
            return
        }

        let page = Page.create(in: viewContext, profile: activeProfile)
        do {
            try viewContext.save()
            self.pageViewModels.append(PageViewModel(page: page, contentViewModel: self))
        } catch let error as NSError {
            self.handleCriticalError(error)
        }
    }

    func movePage( from source: IndexSet, to destination: Int) {
        guard let activeProfile = activeProfile else {
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
                self.handleCriticalError(error)
            }
        }
    }

    func deletePage(indices: IndexSet) {
        guard let activeProfile = activeProfile else {
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
                self.handleCriticalError(error)
            }
        }
    }

    func loadDemo() {
        guard let demoPath = Bundle.main.path(forResource: "Demo", ofType: "opml") else {
            preconditionFailure("Missing demo feeds source file")
        }

        guard let activeProfile = activeProfile else {
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
                self.pageViewModels.append(PageViewModel(page: page, contentViewModel: self))
            }
        } catch let error as NSError {
            self.handleCriticalError(error)
        }
    }

    func showSearch() {
        if activeNav != "search" {
            activeNav = "search"
        }
    }

    private func loadProfiles() {
        do {
            let profiles = try self.viewContext.fetch(Profile.fetchRequest()) as [Profile]
            if profiles.count == 0 {
                activeProfile = createDefault(adoptOrphans: true)
            } else {
                activeProfile = profiles.first
            }
        } catch {
            self.handleCriticalError(error as NSError)
        }
    }

    private func createDefault(adoptOrphans: Bool = false) -> Profile {
        let defaultProfile = Profile.create(in: viewContext)

        if adoptOrphans == true {
            // Adopt existing pages and history for profile upgrade
            do {
                let history = try self.viewContext.fetch(History.fetchRequest()) as [History]
                history.forEach { visit in
                    defaultProfile.addToHistory(visit)
                }
            } catch {
                self.handleCriticalError(error as NSError)
            }

            do {
                let pages = try self.viewContext.fetch(Page.fetchRequest()) as [Page]
                pages.forEach { page in
                    defaultProfile.addToPages(page)
                }
            } catch {
                self.handleCriticalError(error as NSError)
            }
        }

        do {
            try viewContext.save()
        } catch {
            self.handleCriticalError(error as NSError)
        }

        return defaultProfile
    }

    func resetProfiles() {
        activeProfile = createDefault()

        do {
            let profiles = try self.viewContext.fetch(Profile.fetchRequest()) as [Profile]
            profiles.forEach { profile in
                if profile != activeProfile {
                    viewContext.delete(profile)
                }
            }
            do {
                try viewContext.save()
                self.objectWillChange.send()
            } catch {
                self.handleCriticalError(error as NSError)
            }
        } catch {
            self.handleCriticalError(error as NSError)
        }
    }

    private func formatErrorMessage(_ anError: NSError?) -> String {
        guard let anError = anError else { return "Unknown error" }

        guard anError.domain.compare("NSCocoaErrorDomain") == .orderedSame else {
            return "Application error: \(anError)"
        }

        let messages: String = "Unrecoverable data error. \(anError.localizedDescription)"
        var errors = [AnyObject]()

        if anError.code == NSValidationMultipleErrorsError {
            if let multipleErros = anError.userInfo[NSDetailedErrorsKey] as? [AnyObject] {
                errors = multipleErros
            }
        } else {
            errors = [AnyObject]()
            errors.append(anError)
        }

        if errors.count == 0 {
            return ""
        }

        return messages
    }

    public func refresh(pageViewModel: PageViewModel) {
        pageViewModel.refreshing = true
        var operations: [Operation] = []

        pageViewModel.page.feedsArray.forEach { feed in
            pageViewModel.progress.totalUnitCount += 1
            operations.append(
                contentsOf: self.createFeedOps(feed, progress: pageViewModel.progress)
            )
        }

        DispatchQueue.global(qos: .userInitiated).async {
            self.queue.addOperations(operations, waitUntilFinished: true)
            DispatchQueue.main.async {
                self.refreshComplete(page: pageViewModel.page, pageViewModel: pageViewModel)
            }
        }
    }

    public func refresh(feed: Feed, callback: ((Feed) -> Void)? = nil) {
        DispatchQueue.global(qos: .userInitiated).async {
            let operations = self.createFeedOps(feed)
            self.queue.addOperations(operations, waitUntilFinished: true)
            DispatchQueue.main.async {
                self.refreshComplete(page: feed.page)
                if let callback = callback {
                    callback(feed)
                }
            }
        }
    }

    private func createFeedOps(_ feed: Feed, progress: Progress? = nil) -> [Operation] {
        guard let feedData = checkFeedData(feed) else { return [] }

        let refreshPlan = RefreshPlan(
            feed: feed,
            feedData: feedData,
            persistentContainer: persistentContainer,
            progress: progress
        )

        // Fetch meta (favicon, etc.) on first refresh or if user cleared cache, then check for updates occasionally
        if feedData.metaFetched == nil || feedData.metaFetched! < Date(timeIntervalSinceNow: -30 * 24 * 60 * 60) {
            refreshPlan.fullUpdate = true
        }

        refreshPlan.configureOps()

        return refreshPlan.getOps()
    }

    private func checkFeedData(_ feed: Feed) -> FeedData? {
        if let feedData = feed.feedData {
            return feedData
        }

        guard let feedId = feed.id else { return nil }

        let feedData = FeedData.create(in: persistentContainer.viewContext, feedId: feedId)
        do {
            try persistentContainer.viewContext.save()
        } catch {
            self.handleCriticalError(error as NSError)
        }

        return feedData
    }

    private func refreshComplete(page: Page?, pageViewModel: PageViewModel? = nil) {
        pageViewModel?.refreshing = false
        pageViewModel?.progress.completedUnitCount = 0
        pageViewModel?.progress.totalUnitCount = 0

        page?.objectWillChange.send()
        page?.feedsArray.forEach({ feed in
            feed.objectWillChange.send()
        })

        if persistentContainer.viewContext.hasChanges {
            do {
                try persistentContainer.viewContext.save()
            } catch {
                self.handleCriticalError(error as NSError)
            }
        }
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
                openedUrlString = urlString
            }
        }

        self.showingAddSubscription = true
    }

    func resetSubscribe() {
        showingAddSubscription = false
        openedUrlString = ""
    }

    public func openLink(url: URL, logHistoryItem: Item? = nil, readerMode: Bool = false) {
        guard let controller = hostingWindow?.rootViewController else {
            preconditionFailure("No controller present.")
        }

        if let historyItem = logHistoryItem {
            logHistory(item: historyItem)
        }

        let config = SFSafariViewController.Configuration()
        config.entersReaderIfAvailable = readerMode

        let safariViewController = SFSafariViewController(url: url, configuration: config)
        controller.modalPresentationStyle = .fullScreen
        controller.present(safariViewController, animated: true)
    }

    private func logHistory(item: Item) {
        guard let activeProfile = activeProfile else {
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
            handleCriticalError(error as NSError)
        }
    }
}
