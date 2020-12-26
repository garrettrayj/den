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
 Master navigation list with links to Pages. Activating editMode enables CRUD for pages
*/
struct SidebarView: View {
    @Environment(\.managedObjectContext) var viewContext
    @EnvironmentObject var refreshManager: RefreshManager
    @EnvironmentObject var userDefaultsManager: UserDefaultsManager
    @EnvironmentObject var searchManager: SearchManager
    @State var editMode: EditMode = .inactive
    
    var pages: FetchedResults<Page>
    
    let workspaceHeaderHeight: CGFloat = 140

    var body: some View {
        List {
            if pages.count > 0 {
                Section(header: Text("Pages")) {
                    ForEach(self.pages) { page in
                        PageListRowView(page: page, editMode: $editMode)
                    }
                    .onMove(perform: self.move)
                    .onDelete(perform: self.delete)
                }
            } else {
                Section(header: Text("Get Started"), footer: Text("or import subscriptions in settings")) {
                    Button(action: newPage) {
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
            
        
            Section() {
                NavigationLink(
                    destination: SearchView().environmentObject(searchManager)
                ) {
                    Image(systemName: "magnifyingglass").sidebarIconView()
                    Text("Search")
                }
                
                NavigationLink(
                    destination: SettingsView(pages: pages).environmentObject(userDefaultsManager)
                ) {
                    Image(systemName: "gear").sidebarIconView()
                    Text("Settings")
                }
            }
        }
        .animation(nil)
        .listStyle(GroupedListStyle())
        .navigationTitle("Den")
        .navigationBarItems(trailing: HStack {
            Button(action: { withAnimation { let _ = Page.create(in: self.viewContext) }}) {
                Image(systemName: "plus").titleBarIconView()
            }
            EditButton()
        })
        .environment(\.editMode, self.$editMode)
        
        
        
        
        /*
        VStack(spacing: 0) {
            if pages.count == 0 && UIDevice.current.userInterfaceIdiom == UIUserInterfaceIdiom.phone {
                Spacer()
            }
            
            if pages.count == 0 {
                VStack(alignment: .center, spacing: 16) {
                    Image("TitleIcon").resizable().scaledToFit().frame(width: 72, height: 72)
                    Text("Get Started").font(.title).fontWeight(.semibold)
                    Button(action: newPage) {
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
                    NavigationLink(destination: ImportView()) {
                        HStack {
                            Image(systemName: "arrow.down.doc")
                            Text("Import OPML File").fontWeight(.medium)
                        }
                    }
                }
                .frame(maxWidth: .infinity)
                .buttonStyle(BorderedButtonStyle())
                
                Spacer()
                Spacer()
                Spacer()
            } else {
                HeaderProgressBarView(refreshables: pages.map { $0 })
                    .frame(height: refreshManager.isRefreshing(pages.map { $0 }) ? 2 : 0)
                
                PageListView(editMode: $editMode, pages: pages)
            }
            
            if pages.count > 0 && editMode == .inactive {
                HStack {
                    NavigationLink(
                        destination: SettingsView(pages: pages).environmentObject(userDefaultsManager)
                    ) {
                        Image(systemName: "gear").titleBarIconView()
                    }
                    Spacer()
                    
                    NavigationLink(
                        destination: SearchView().environmentObject(searchManager)
                    ) {
                        Image(systemName: "magnifyingglass").titleBarIconView()
                    }
                }.padding(4)
            } else if editMode == .active {
                HStack {
                    Spacer()
                    Button(action: { withAnimation { let _ = Page.create(in: self.viewContext) }}) {
                        Image(systemName: "plus").titleBarIconView()
                    }
                }.padding(4)
            }
        }
        .padding(.top, 1)
        .navigationBarItems(
            trailing: HStack {
                if pages.count > 0 {
                    if self.editMode == .active {
                        Button(action: doneEditing) {
                            Text("Done").background(Color.clear).padding(12)
                        }.offset(x: 12)
                    } else {
                        Button(action: { self.editMode = .active }) {
                            Text("Edit").background(Color.clear).padding(12)
                        }.offset(x: 12)
                    }
                }
            }
        )
        */
    }
    
    var intro: some View {
        VStack(alignment: .center, spacing: 16) {
            Image("TitleIcon").resizable().scaledToFit().frame(width: 72, height: 72)
            Text("Get Started").font(.title).fontWeight(.semibold)
            Button(action: newPage) {
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
            NavigationLink(destination: ImportView()) {
                HStack {
                    Image(systemName: "arrow.down.doc")
                    Text("Import OPML File").fontWeight(.medium)
                }
            }
        }
        .frame(maxWidth: .infinity)
        .buttonStyle(BorderedButtonStyle())
    }
    
    func doneEditing() {
        self.editMode = .inactive
    }
    
    func newPage() {
        let _ = Page.create(in: viewContext)
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
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
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
        } catch {
            fatalError("Unable to save import context: \(error)")
        }
        
        refreshManager.refresh(newPages)
    }
}
