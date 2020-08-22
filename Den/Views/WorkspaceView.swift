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
                
                VStack(alignment: .center, spacing: 4) {
                    Image("TitleIcon").resizable().scaledToFit().frame(width: 48, height: 48)
                    Text("Den").font(.title).fontWeight(.semibold)
                }.padding(.top, -90).padding(.horizontal).padding(.bottom, 8).frame(maxWidth: .infinity)
                
                if workspace.isEmpty {
                    VStack(alignment: .center, spacing: 16) {
                        Text("Get Started").font(.headline)
                        Button(action: newPage) {
                            Text("Create a New Page").fontWeight(.medium)
                        }
                        Button(action: loadDemo) {
                            Text("Load Demo Feeds").fontWeight(.medium)
                        }
                        Text("or")
                        Text("Import feeds in Settings").multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity)
                    .buttonStyle(BorderedButtonStyle())
                    
                    Spacer()
                } else {
                    if refreshManager.isRefreshing(workspace) {
                        HeaderProgressBarView(refreshable: workspace).frame(height: 2)
                    }
                    PageListView(editMode: $editMode, workspace: workspace)
                }
            }
            HStack {
                NavigationLink(destination: SettingsView(workspace: workspace).environmentObject(userDefaultsManager)) {
                    Image(systemName: "gear")
                }
                Spacer()
            }.padding()
        }
        .navigationBarTitle("")
        .navigationBarItems(
            leading: HStack {
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
            },
            trailing: HStack {
                if !workspace.isEmpty {
                    if self.editMode == .active {
                        Button(action: { withAnimation { let _ = Page.create(in: self.viewContext, workspace: self.workspace) }}) {
                            Image(systemName: "plus").background(Color.clear)
                        }
                    } else {
                        Button(action: { self.refreshManager.refresh(self.workspace)}) {
                            Image(systemName: "arrow.clockwise").background(Color.clear)
                        }
                        .disabled(refreshManager.refreshing)
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
