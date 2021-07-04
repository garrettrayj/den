//
//  WorkspaceView.swift
//  Den
//
//  Created by Garrett Johnson on 5/18/20.
//  Copyright © 2020 Garrett Johnson. All rights reserved.
//

import Foundation
import SwiftUI
import CoreData

/**
 Master navigation list with links to page views.
*/
struct SidebarView: View {
    @Environment(\.managedObjectContext) var viewContext
    @Environment(\.presentationMode) var presentation
    @Environment(\.editMode) var editMode
    @EnvironmentObject var profileManager: ProfileManager
    @EnvironmentObject var refreshManager: RefreshManager
    @EnvironmentObject var crashManager: CrashManager

    @State var pageSelection: String?

    var body: some View {
        List {
            if profileManager.activeProfile?.pagesArray.count ?? 0 > 0 {
                pageListSection
            } else {
                getStartedSection
            }
        }
        .environment(\.editMode, editMode)
        .animation(nil)
        .listStyle(InsetGroupedListStyle())
        .navigationTitle("Den")
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                Button(action: createPage) {
                    Label("Create Page", systemImage: "plus")
                }
                EditButton()
            }
        }
        .onAppear {
            if pageSelection == nil && UIDevice.current.userInterfaceIdiom != .phone {
                pageSelection = profileManager.activeProfile?.pagesArray.first?.id?.uuidString
            }
        }

    }

    private var pageListSection: some View {
        Section {
            ForEach(profileManager.activeProfile!.pagesArray) { page in
                PageListRowView(page: page, pageSelection: $pageSelection)
            }
            .onMove(perform: self.movePage)
            .onDelete(perform: self.deletePage)
        }
    }

    private var getStartedSection: some View {
        Section(
            header: Text("Get Started"),
            footer: Text("or import subscriptions in settings.")
        ) {
            Button(action: createPage) {
                HStack {
                    Image(systemName: "plus")
                    Text("Create a New Page").fontWeight(.medium)
                }
            }
            Button(action: loadDemo) {
                HStack {
                    Image(systemName: "wand.and.stars")
                    Text("Load Demo Feeds").fontWeight(.medium)
                }
            }
        }
    }

    private func createPage() {
        _ = Page.create(in: viewContext, profile: profileManager.activeProfile!)
        do {
            try viewContext.save()
            profileManager.activeProfile?.objectWillChange.send()
        } catch let error as NSError {
            crashManager.handleCriticalError(error)
        }
    }

    private func movePage( from source: IndexSet, to destination: Int) {
        guard var revisedItems = profileManager.activeProfile?.pagesArray else { return }

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
                profileManager.activeProfile?.objectWillChange.send()
            } catch let error as NSError {
                crashManager.handleCriticalError(error)
            }
        }
    }

    private func deletePage(indices: IndexSet) {
        profileManager.activeProfile?.pagesArray.delete(at: indices, from: viewContext)
        profileManager.activeProfile?.objectWillChange.send()
    }

    private func loadDemo() {
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
            profileManager.activeProfile?.objectWillChange.send()
        } catch let error as NSError {
            crashManager.handleCriticalError(error)
        }
    }
}
