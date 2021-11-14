//
//  WorkspaceView.swift
//  Den
//
//  Created by Garrett Johnson on 5/18/20.
//  Copyright © 2020 Garrett Johnson. All rights reserved.
//

import SwiftUI

/**
 Master navigation list with links to page views.
*/
struct SidebarView: View {
    @Environment(\.managedObjectContext) var viewContext
    @Environment(\.editMode) var editMode
    @EnvironmentObject var crashManager: CrashManager
    @EnvironmentObject var refreshManager: RefreshManager
    @EnvironmentObject var profileManager: ProfileManager

    @State var activeNav: String?

    @StateObject var searchViewModel: SearchViewModel

    /**
     Switch refreshable() on and off depending on environment and page count.
     
         SwiftUI.SwiftUI_UIRefreshControl is not supported when running Catalyst apps in the Mac idiom.
         See UIBehavioralStyle for possible alternatives.
         Consider using a Refresh menu item bound to ⌘-R
     */
    var body: some View {
        Group {
            if editMode?.wrappedValue == .active {
                editingList.environment(\.editMode, editMode)
            } else {
                if profileManager.activeProfile?.pagesArray.count ?? 0 > 0 {
                    #if targetEnvironment(macCatalyst)
                    navigationList
                    #else
                    navigationList.refreshable {
                        refreshAll()
                    }
                    #endif
                } else {
                    getStartedList
                }

            }
        }
        .listStyle(SidebarListStyle())
        .navigationTitle("Den")
        .navigationBarTitleDisplayMode(.large)
        .toolbar { toolbar }
    }

    private var navigationList: some View {
        List {
            pageListSection

            moreSection
        }
        .background(
            NavigationLink(tag: "search", selection: $activeNav) {
                SearchView(viewModel: searchViewModel)
            } label: {
                Text("Search")
            }.hidden()
        )
        .searchable(
            text: $searchViewModel.searchText,
            placement: .navigationBarDrawer(displayMode: .always),
            prompt: Text("Search")
        )
        .onSubmit(of: .search) {
            showSearch()
            searchViewModel.performItemSearch()
        }
    }

    private var editingList: some View {
        List {
            editListSection
            Button(action: createPage) {
                Label("New Page", systemImage: "plus.circle")
            }
            Spacer().listRowBackground(Color.clear)
        }
    }

    private var toolbar: some ToolbarContent {
        ToolbarItemGroup(placement: .navigationBarTrailing) {
            HStack(spacing: 0) {
                if editMode?.wrappedValue == .active {
                    Button {
                        editMode?.wrappedValue = .inactive
                    } label: {
                        Text("Done")
                    }
                }

                if editMode?.wrappedValue == .inactive && profileManager.activeProfile?.pagesArray.count ?? 0 > 0 {
                    Button {
                        editMode?.wrappedValue = .active
                    } label: {
                        Text("Edit")
                    }

                    Button {
                        NotificationCenter.default.post(name: .refreshAll, object: nil)
                    } label: {
                        Label("Refresh All", systemImage: "arrow.clockwise")
                    }
                }
            }.buttonStyle(ToolbarButtonStyle())
        }
    }

    private var editListSection: some View {
        Section(header: Text("Pages").modifier(SidebarSectionHeaderModifier())) {
            ForEach(profileManager.activeProfile?.pagesArray ?? []) { page in
                Label(
                    title: {
                        Text(page.displayName).lineLimit(1)
                    },
                    icon: {
                        Image(systemName: page.wrappedSymbol).foregroundColor(.primary)
                    }
                ).offset(x: -36)
            }
            .onMove(perform: movePage)
        }
    }

    private var pageListSection: some View {
        Section(header: Text("Pages").modifier(SidebarSectionHeaderModifier())) {
            ForEach(profileManager.activeProfile?.pagesArray ?? []) { page in
                SidebarPageView(
                    activeNav: $activeNav,
                    viewModel: PageViewModel(
                        page: page,
                        viewContext: viewContext,
                        crashManager: crashManager
                    )
                )
            }
        }
    }

    private var getStartedList: some View {
        List {
            Section(header: Text("Get Started").modifier(SidebarSectionHeaderModifier())) {
                Button(action: createPage) {
                    Label("New Page", systemImage: "plus").padding(.vertical, 4)
                }
                Button(action: loadDemo) {
                    Label("Load Demo", systemImage: "wand.and.stars").padding(.vertical, 4)
                }
            }
        }
    }

    private var moreSection: some View {
        Group {
            if profileManager.activeProfile?.pagesArray.count ?? 0 > 0 {
                NavigationLink(tag: "history", selection: $activeNav) {
                    HistoryView(viewModel: HistoryViewModel(
                        viewContext: viewContext,
                        crashManager: crashManager
                    ))
                } label: {
                    Label {
                        Text("History")
                    } icon: {
                        Image(systemName: "clock").foregroundColor(.primary)
                    }
                }
            }

            NavigationLink(tag: "settings", selection: $activeNav) {
                SettingsView()
            } label: {
                Label {
                    Text("Settings")
                } icon: {
                    Image(systemName: "gear").foregroundColor(.primary)
                }

            }
        }
    }

    private func showSearch() {
        if activeNav != "search" {
            activeNav = "search"
        }
    }

    private func refreshAll() {
        NotificationCenter.default.post(name: .refreshAll, object: nil)
    }

    private func createPage() {
        guard let profile = profileManager.activeProfile else { return }

        _ = Page.create(in: viewContext, profile: profile)

        do {
            try viewContext.save()
        } catch let error as NSError {
            crashManager.handleCriticalError(error)
        }
    }

    private func movePage( from source: IndexSet, to destination: Int) {
        guard let profile = profileManager.activeProfile else { return }

        var revisedItems = profile.pagesArray

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

    private func deletePage(indices: IndexSet) {
        guard let profile = profileManager.activeProfile else { return }

        indices.forEach {
            viewContext.delete(profile.pagesArray[$0])
        }

        if viewContext.hasChanges {
            do {
                try viewContext.save()
            } catch let error as NSError {
                crashManager.handleCriticalError(error)
            }
        }
    }

    private func loadDemo() {
        guard let demoPath = Bundle.main.path(forResource: "Demo", ofType: "opml") else {
            preconditionFailure("Missing demo feeds source file")
        }

        guard let profile = profileManager.activeProfile else { return }

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
            profileManager.objectWillChange.send()
        } catch let error as NSError {
            crashManager.handleCriticalError(error)
        }
    }
}
