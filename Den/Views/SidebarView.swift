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
    @EnvironmentObject var crashManager: CrashManager
    @EnvironmentObject var refreshManager: RefreshManager
    @EnvironmentObject var profileManager: ProfileManager

    @StateObject var searchViewModel: SearchViewModel

    @State var editingPages: Bool = false
    @State var showingSearch: Bool = false
    @State var showingHistory: Bool = false
    @State var showingSettings: Bool = false

    /**
     Switch refreshable() on and off depending on environment and page count.
     
         SwiftUI.SwiftUI_UIRefreshControl is not supported when running Catalyst apps in the Mac idiom.
         See UIBehavioralStyle for possible alternatives.
         Consider using a Refresh menu item bound to ⌘-R
     */
    var body: some View {
        Group {
            if editingPages {
                editingList
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
        .background(
            Group {
                NavigationLink(isActive: $showingSearch) {
                    SearchView(viewModel: searchViewModel)
                } label: {
                    Text("Search")
                }.hidden()

                NavigationLink(isActive: $showingHistory) {
                    HistoryView(viewModel: HistoryViewModel(
                        viewContext: viewContext,
                        crashManager: crashManager
                    ))
                } label: {
                    Label("History", systemImage: "clock")
                }.hidden()

                NavigationLink(isActive: $showingSettings) {
                    SettingsView()
                } label: {
                    Label("Settings", systemImage: "gear")
                }.hidden()
            }
        )
    }

    private var navigationList: some View {
        List {
            ForEach(profileManager.activeProfile?.pagesArray ?? []) { page in
                SidebarPageView(page: page)
                    #if targetEnvironment(macCatalyst)
                    .listRowInsets(EdgeInsets())
                    #endif
            }
        }
        .listStyle(.sidebar)
        .searchable(
            text: $searchViewModel.searchText,
            placement: .navigationBarDrawer(displayMode: .always),
            prompt: Text("Search")
        )
        .onSubmit(of: .search) {
            showSearch()
            searchViewModel.performItemSearch()
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    editingPages = true
                } label: {
                    Label("Edit", systemImage: "slider.horizontal.3").lineLimit(1)
                }
                .buttonStyle(NavigationBarButtonStyle())
            }

            #if targetEnvironment(macCatalyst)
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: refreshAll) {
                    Label("Refresh", systemImage: "arrow.clockwise")
                }
                .buttonStyle(NavigationBarButtonStyle())
                .keyboardShortcut("r", modifiers: [.command, .shift])
            }
            #endif

            ToolbarItem(placement: .bottomBar) {
                Button {
                    showingSettings = true
                } label: {
                    Label("Settings", systemImage: "gear")
                }
            }

            ToolbarItem(placement: .bottomBar) {
                Button {
                    showingHistory = true
                } label: {
                    Label("History", systemImage: "clock")
                }
            }
        }
        .background(
            Group {
                #if !targetEnvironment(macCatalyst)
                Button(action: refreshAll) {
                    Label("Refresh", systemImage: "arrow.clockwise")
                }
                .buttonStyle(NavigationBarButtonStyle())
                .keyboardShortcut("r", modifiers: [.command, .shift])
                #endif
            }.hidden()
        )
        .navigationBarTitleDisplayMode(.inline)
    }

    private var editingList: some View {
        List {
            Section(
                header: HStack {
                    Text("\(profileManager.activeProfile?.pagesArray.count ?? 0) Pages")
                    Spacer()
                    Text("Drag to Reorder")
                }.modifier(SectionHeaderModifier())
            ) {
                ForEach(profileManager.activeProfile?.pagesArray ?? []) { page in
                    Text(page.displayName)
                        .lineLimit(1)
                        #if targetEnvironment(macCatalyst)
                        .font(.title3)
                        .padding(.vertical, 8)
                        .padding(.leading, 6)
                        .listRowInsets(EdgeInsets())
                        #endif
                }
                .onMove(perform: movePage)
                .onDelete(perform: deletePage)
            }
        }
        #if targetEnvironment(macCatalyst)
        .listStyle(.grouped)
        .padding(.top, 10)
        #else
        .listStyle(.insetGrouped)
        #endif
        .environment(\.editMode, .constant(.active))
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    editingPages = false
                } label: {
                    Text("Done").lineLimit(1)
                }.buttonStyle(NavigationBarButtonStyle())
            }

            ToolbarItem(placement: .bottomBar) {
                Button(action: createPage) {
                    Label("New Page", systemImage: "plus.circle").labelStyle(.titleAndIcon)
                }.buttonStyle(NavigationBarButtonStyle())
            }
        }
    }

    private var getStartedList: some View {
        List {
            Section {
                Button(action: createPage) {
                    Label("Create a New Page", systemImage: "plus")
                }
                Button(action: loadDemo) {
                    Label("Load Demo Feeds", systemImage: "wand.and.stars")
                }
            }
            .listRowInsets(EdgeInsets(top: 8, leading: 4, bottom: 8, trailing: 4))
            .font(.title3)
        }
        .listStyle(.inset)
        .toolbar {
            ToolbarItem(placement: .bottomBar) {
                Button {
                    showingSettings = true
                } label: {
                    Label("Settings", systemImage: "gear").labelStyle(.titleAndIcon)
                }.buttonStyle(NavigationBarButtonStyle())
            }
        }
        .navigationTitle("Start")
        .navigationBarTitleDisplayMode(.large)
    }

    private func refreshAll() {
        refreshManager.refresh(pages: profileManager.activeProfile?.pagesArray ?? [])
    }

    private func showSearch() {
        if !showingSearch {
            showingSearch = true
        }
    }

    private func createPage() {
        guard let profile = profileManager.activeProfile else { return }
        _ = Page.create(in: viewContext, profile: profile)

        do {
            try viewContext.save()
            profileManager.objectWillChange.send()
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
                profileManager.objectWillChange.send()
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
