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
    @EnvironmentObject var crashManager: CrashManager
    
    @ObservedObject var mainViewModel: MainViewModel
    
    @State var pageSelection: String?
    
    var body: some View {
        VStack {
            List {
                if mainViewModel.activeProfile!.pagesArray.count > 0 {
                    pageList
                } else {
                    getStartedSection
                }
            }
            .animation(nil)
            .listStyle(InsetGroupedListStyle())
            .navigationTitle("Den")
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
        .onAppear {
            if pageSelection == nil {
                pageSelection = mainViewModel.activeProfile?.pagesArray.first?.id?.uuidString
            }
        }
        
    }
    
    var pageList: some View {
        ForEach(mainViewModel.activeProfile!.pagesArray) { page in
            PageListRowView(page: page, mainViewModel: mainViewModel, pageSelection: $pageSelection)
        }
        .onMove(perform: self.move)
        .onDelete(perform: self.delete)
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
    
    func doneEditing() {
        self.mainViewModel.sidebarEditMode = .inactive
    }
    
    func createPage() {
        let _ = Page.create(in: viewContext, profile: mainViewModel.activeProfile!)
        do {
            try viewContext.save()
        } catch let error as NSError {
            crashManager.handleCriticalError(error)
        }
    }
    
    private func move( from source: IndexSet, to destination: Int) {
        var revisedItems = mainViewModel.activeProfile!.pagesArray

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
        mainViewModel.activeProfile!.pagesArray.delete(at: indices, from: viewContext)
    }
    
    func loadDemo() {
        guard let demoPath = Bundle.main.path(forResource: "DemoWorkspace", ofType: "opml") else {
            preconditionFailure("Missing demo feeds source file")
        }
        
        let opmlReader = OPMLReader(xmlURL: URL(fileURLWithPath: demoPath))
        
        var newPages: [Page] = []
        opmlReader.outlineFolders.forEach { opmlFolder in
            let page = Page.create(in: self.viewContext, profile: mainViewModel.activeProfile!)
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
        
        mainViewModel.objectWillChange.send()
    }
}
