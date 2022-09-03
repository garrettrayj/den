//
//  SidebarView.swift
//  Den
//
//  Created by Garrett Johnson on 12/6/21.
//  Copyright © 2021 Garrett Johnson. All rights reserved.
//

import CoreData
import SwiftUI

enum Panel: Hashable {
    case welcome
    case search
    case allItems
    case trends
    case page(Page.ID)
    case settings
}

struct SidebarView: View {
    @Environment(\.editMode) private var editMode
    @Environment(\.managedObjectContext) private var viewContext

    @ObservedObject var profile: Profile

    @Binding var selection: Panel?
    @Binding var refreshing: Bool
    @Binding var searchInput: String

    let persistentContainer: NSPersistentContainer
    let refreshProgress: Progress

    var body: some View {
        List(selection: $selection) {
            if profile.pagesArray.isEmpty {
                Section {
                    Button {
                        withAnimation {
                            _ = Page.create(in: viewContext, profile: profile, prepend: true)
                            save()
                        }
                    } label: {
                        Label("Create Blank Page", systemImage: "plus")
                    }
                    .modifier(StartRowModifier())
                    .accessibilityIdentifier("start-blank-page-button")

                    Button(action: loadDemo) {
                        Label("Load Demo Feeds", systemImage: "wand.and.stars")
                    }
                    .modifier(StartRowModifier())
                    .accessibilityIdentifier("load-demo-button")
                } header: {
                    Text("Get Started")
                } footer: {
                    Text("or import feeds in settings")
                    #if targetEnvironment(macCatalyst)
                        .font(.system(size: 13)).padding(.vertical, 12)
                    #endif
                }
                .lineLimit(1)
                .modifier(SectionHeaderModifier())
            } else {
                AllItemsNavView(
                    profile: profile,
                    unreadCount: profile.previewItems.unread().count,
                    refreshing: $refreshing
                )
                TrendsNavView(profile: profile, refreshing: $refreshing)

                Section {
                    ForEach(profile.pagesArray) { page in
                        PageNavView(
                            page: page,
                            unreadCount: page.previewItems.unread().count,
                            refreshing: $refreshing,
                            selection: $selection
                        )
                    }
                    .onMove(perform: movePage)
                    .onDelete(perform: deletePage)
                } header: {
                    Text("Pages")
                    #if targetEnvironment(macCatalyst)
                        .font(.callout).padding(.top, 4)
                    #endif
                }

            }

        }

        .searchable(
            text: $searchInput,
            placement: .navigationBarDrawer(displayMode: .always),
            prompt: Text("Search")
        )
        .onSubmit(of: .search) {
            selection = .search
        }
        #if !targetEnvironment(macCatalyst)
        .refreshable {
            if !refreshing {
                RefreshManager.refresh(container: persistentContainer, profile: profile)
            }
        }
        #endif
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    withAnimation {
                        _ = Page.create(in: viewContext, profile: profile, prepend: true)
                        save()
                    }
                } label: {
                    Label("New Page", systemImage: "plus")
                }
                .disabled(refreshing)
                .accessibilityIdentifier("new-page-button")
            }

            ToolbarItem(placement: .navigationBarTrailing) {
                EditButton()
                    .disabled(refreshing)
                    .accessibilityIdentifier("edit-page-list-button")
            }

            ToolbarItemGroup(placement: .bottomBar) {
                Button {
                    selection = .settings
                } label: {
                    Label("Settings", systemImage: "gear")
                }
                .accessibilityIdentifier("settings-button")
                .disabled(refreshing)

                Spacer()

                VStack {
                    if refreshing {
                        ProgressView(refreshProgress)
                            .progressViewStyle(BottomBarProgressStyle(progress: refreshProgress))
                    } else {
                        refreshedLabel
                    }
                }
                .font(.caption)
                .padding(.horizontal)

                Spacer()

                Button {
                    RefreshManager.refresh(container: persistentContainer, profile: profile)
                } label: {
                    Label("Refresh", systemImage: "arrow.clockwise")
                }
                .keyboardShortcut("r", modifiers: [.command])
                .accessibilityIdentifier("profile-refresh-button")
                .disabled(refreshing)
            }
        }
    }

    var refreshedLabel: some View {
        VStack(alignment: .center, spacing: 0) {
            if profile.minimumRefreshedDate != nil {
                Text("Updated \(profile.minimumRefreshedDate!.shortShortDisplay())")
            } else {
                #if targetEnvironment(macCatalyst)
                Text("Press \(Image(systemName: "command")) + R to refresh").imageScale(.small)
                #else
                Text("Pull to refresh")
                #endif
            }
        }.lineLimit(1)
    }

    private func save() {
        if viewContext.hasChanges {
            do {
                try viewContext.save()
            } catch {
                CrashManager.handleCriticalError(error as NSError)
            }
        }
    }

    private func movePage( from source: IndexSet, to destination: Int) {
        var revisedItems = profile.pagesArray

        // change the order of the items in the array
        revisedItems.move(fromOffsets: source, toOffset: destination)

        // update the userOrder attribute in revisedItems to
        // persist the new order. This is done in reverse order
        // to minimize changes to the indices.
        for reverseIndex in stride(from: revisedItems.count - 1, through: 0, by: -1 ) {
            revisedItems[reverseIndex].userOrder = Int16(reverseIndex)
        }
        save()
    }

    private func deletePage(indices: IndexSet) {
        indices.forEach {
            viewContext.delete(profile.pagesArray[$0])
            profile.objectWillChange.send()
        }
        save()
    }

    private func loadDemo() {
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
            profile.objectWillChange.send()
        } catch let error as NSError {
            DispatchQueue.main.async {
                CrashManager.handleCriticalError(error)
            }
        }
    }
}
