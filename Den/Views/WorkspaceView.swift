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
struct WorkspaceView: View {
    @Environment(\.managedObjectContext) var viewContext
    @EnvironmentObject var screenManager: ScreenManager
    @EnvironmentObject var refreshManager: RefreshManager
    @EnvironmentObject var subscriptionManager: SubscriptionManager
    @EnvironmentObject var userDefaultsManager: UserDefaultsManager
    @State var editMode: EditMode = .inactive
    
    var pages: FetchedResults<Page>
    
    let workspaceHeaderHeight: CGFloat = 140

    var body: some View {
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
                    .navigationBarTitle("Den", displayMode: .large)
            }
            
            Spacer()
            
            if pages.count > 0 {
                HStack {
                    NavigationLink(
                        destination: SettingsView(pages: pages).environmentObject(userDefaultsManager),
                        tag: "settings",
                        selection: $screenManager.activePage
                    ) {
                        Image(systemName: "gear").titleBarIconView()
                    }
                    Spacer()
                }.padding(4)
            }
        }
        .padding(.top, 1)
        .navigationBarItems(
            leading: HStack {
                if pages.count > 0 {
                    if self.editMode == .active {
                        Button(action: { withAnimation { let _ = Page.create(in: self.viewContext) }}) {
                            Image(systemName: "plus").titleBarIconView()
                        }.offset(x: -12)
                    } else {
                        Button(action: { self.refreshManager.refresh(self.pages.map { $0 }) }) {
                            Image(systemName: "arrow.clockwise").titleBarIconView()
                        }
                        .disabled(refreshManager.refreshing)
                        .offset(x: -12)
                    }
                }
            },
            trailing: HStack {
                if pages.count > 0 {
                    if self.editMode == .active {
                        Button(action: doneEditing) {
                            Text("Done").background(Color.clear).padding(12)
                        }.offset(x: 12)
                    } else {
                        Button(action: { self.editMode = .active }) {
                            Image(systemName: "list.bullet").titleBarIconView()
                        }.offset(x: 12)
                    }
                }
            }
        ).sheet(isPresented: $subscriptionManager.showSubscribeView) {
            if self.pages.count > 0 {
                SubscribeView(page: self.subscriptionManager.currentPage != nil ? self.subscriptionManager.currentPage! : self.pages.first!)
                    .environment(\.managedObjectContext, self.viewContext)
                    .environmentObject(self.refreshManager)
                    .environmentObject(self.subscriptionManager)
            } else {
                VStack(spacing: 16) {
                    Text("Page Required").font(.title)
                    Text("Create a new page before subscribing to feeds.")
                    Button(action: { self.subscriptionManager.reset() }) {
                        Text("Close").fontWeight(.medium)
                    }.buttonStyle(BorderedButtonStyle())
                }
            }
        }
    }
    
    func doneEditing() {
        self.editMode = .inactive
    }
    
    func newPage() {
        let _ = Page.create(in: viewContext)
    }
    
    func loadDemo() {
        guard let demoPath = Bundle.main.path(forResource: "DemoWorkspace", ofType: "opml") else {
            preconditionFailure("Missing demo feeds source file")
        }
        let opmlReader = OPMLReader(xmlURL: URL(fileURLWithPath: demoPath))
        
        opmlReader.outlineFolders.forEach { opmlFolder in
            let page = Page.create(in: self.viewContext)
            page.name = opmlFolder.name
            
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
        
        refreshManager.refresh(pages.map { $0 })
    }
}
