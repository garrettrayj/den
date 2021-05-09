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
    @EnvironmentObject var refreshManager: RefreshManager
    @EnvironmentObject var searchManager: SearchManager
    @EnvironmentObject var crashManager: CrashManager
    
    @ObservedObject var mainViewModel: MainViewModel
    
    var pages: FetchedResults<Page>

    var body: some View {
        VStack {
            List {
                if pages.count > 0 {
                    pageList
                } else {
                    getStartedSection
                }
                moreSection
            }
            .animation(nil)
            .listStyle(InsetGroupedListStyle())
            .navigationBarTitleDisplayMode(.large)
            .navigationTitle(Text("Den"))
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    Button(action: { withAnimation { createPage() }}) {
                        Image(systemName: "plus")
                    }
                    EditButton()
                }
            }
            .environment(\.editMode, self.$mainViewModel.sidebarEditMode)
        }
        
    }
    
    var pageList: some View {
        Section(header: Text("Pages")) {
            ForEach(self.pages) { page in
                PageListRowView(page: page, mainViewModel: mainViewModel)
            }
            .onMove(perform: self.move)
            .onDelete(perform: self.delete)
        }
    }
    
    var getStartedSection: some View {
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
    
    var moreSection: some View {
        Section() {
            NavigationLink(destination: SearchView(), tag: "search", selection: $mainViewModel.navSelection) {
                Image(systemName: "magnifyingglass")
                Text("Search")
            }
            
            NavigationLink(destination: SettingsView(mainViewModel: mainViewModel, pages: pages), tag: "settings", selection: $mainViewModel.navSelection) {
                Image(systemName: "gear")
                Text("Settings")
            }
        }
    }
    
    func doneEditing() {
        self.mainViewModel.sidebarEditMode = .inactive
    }
    
    func createPage() {
        let _ = Page.create(in: viewContext)
        do {
            try viewContext.save()
        } catch let error as NSError {
            crashManager.handleCriticalError(error)
        }
    }
    
    private func move( from source: IndexSet, to destination: Int) {
        // Make an array of items from fetched results
        var revisedItems: [Page] = pages.map { $0 }

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
    
    func delete(indices: IndexSet) {
        pages.delete(at: indices, from: viewContext)
    }
    
    func loadDemo() {
        var newPages: [Page] = []
        guard let demoPath = Bundle.main.path(forResource: "DemoWorkspace", ofType: "opml") else {
            preconditionFailure("Missing demo feeds source file")
        }
        let opmlReader = OPMLReader(xmlURL: URL(fileURLWithPath: demoPath))
        
        opmlReader.outlineFolders.forEach { opmlFolder in
            let page = Page.create(in: self.viewContext)
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
        } catch let error as NSError {
            crashManager.handleCriticalError(error)
        }
    }
}
