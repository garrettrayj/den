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
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var refreshManager: RefreshManager
    @EnvironmentObject var subscriptionManager: SubscriptionManager
    @EnvironmentObject var userDefaultsManager: UserDefaultsManager
    @ObservedObject var workspace: Workspace
    @State var editMode: EditMode = .inactive
    
    var body: some View {
        VStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 0) {
                if workspace.isEmpty && UIDevice.current.userInterfaceIdiom == UIUserInterfaceIdiom.phone {
                    Spacer()
                }
                
                if workspace.isEmpty {
                    appHeader
                    
                    VStack(alignment: .center, spacing: 16) {
                        Text("Start Here").font(.title)
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
                        NavigationLink(destination: ImportView(workspace: workspace)) {
                            HStack {
                                Image(systemName: "arrow.down.doc")
                                Text("Import OPML")
                            }
                            
                        }
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .buttonStyle(BorderedButtonStyle())
                    
                    Spacer()
                } else {
                    ZStack(alignment: .top) {
                        VStack(spacing: 0) {
                            if refreshManager.isRefreshing(workspace) {
                                HeaderProgressBarView(refreshable: workspace).frame(height: 2)
                            }
                            Divider()
                            PageListView(editMode: $editMode, workspace: workspace)
                        }.padding(.top, 140)
                        
                        appHeader
                    }
                }
            }
            
            if !workspace.isEmpty {
                Divider()
                HStack {
                    NavigationLink(destination: SettingsView(workspace: workspace).environmentObject(userDefaultsManager)) {
                        Image(systemName: "gear")
                    }
                    Spacer()
                }.padding()
            }
        }
        .edgesIgnoringSafeArea(.top)
        .navigationBarTitle("", displayMode: .large)
        .navigationBarItems(
            leading: HStack {
                if !workspace.isEmpty {
                    if self.editMode == .active {
                        Button(action: { withAnimation { let _ = Page.create(in: self.viewContext, workspace: self.workspace) }}) {
                            Image(systemName: "plus").background(Color.clear)
                        }
                    } else {
                        Button(action: { self.refreshManager.refresh(self.workspace) }) {
                            Image(systemName: "arrow.clockwise").background(Color.clear)
                        }
                        .disabled(refreshManager.refreshing)
                    }
                }
            },
            trailing: HStack {
                if !workspace.isEmpty {
                    if self.editMode == .active {
                        Button(action: doneEditing) {
                            Text("Done").background(Color.clear)
                        }
                    } else {
                        Button(action: { self.editMode = .active }) {
                            Text("Edit").background(Color.clear)
                        }
                    }
                }
            }
        ).sheet(isPresented: $subscriptionManager.showSubscribeView) {
            if !self.workspace.isEmpty {
                SubscribeView(page: self.subscriptionManager.currentPage != nil ? self.subscriptionManager.currentPage! : self.workspace.pagesArray.first!)
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
    
    var appHeader: some View {
        VStack {
            Spacer()
            HStack(alignment: .center, spacing: 10) {
                Image("TitleIcon").resizable().scaledToFit().frame(width: 38, height: 38)
                Text("Den")
                    .font(.title)
                    .fontWeight(.bold)
            }.padding(.bottom, 24)
        }
        .padding(.horizontal)
        .frame(maxWidth: .infinity)
        .frame(height: 140)
        .background(Color(UIColor.systemBackground)) //
    }
    
    func doneEditing() {
        self.editMode = .inactive
    }
    
    func newPage() {
        let _ = Page.create(in: viewContext, workspace: workspace)
    }
    
    func loadDemo() {
        guard let demoPath = Bundle.main.path(forResource: "DemoWorkspace", ofType: "opml") else {
            fatalError("Missing demo feeds source file")
        }
        let opmlReader = OPMLReader(xmlURL: URL(fileURLWithPath: demoPath))
        
        opmlReader.outlineFolders.forEach { opmlFolder in
            let page = Page.create(in: viewContext, workspace: workspace)
            page.name = opmlFolder.name
            
            opmlFolder.feeds.forEach { opmlFeed in
                let feed = Feed.create(in: viewContext, page: page)
                feed.title = opmlFeed.title
                feed.url = opmlFeed.url
            }
        }
        
        refreshManager.refresh(workspace)
    }
}
