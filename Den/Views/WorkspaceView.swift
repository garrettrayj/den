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
    @EnvironmentObject var refreshManager: RefreshManager
    @EnvironmentObject var subscriptionManager: SubscriptionManager
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
                }.padding(.top, -82).padding(.horizontal).padding(.bottom, 8).frame(maxWidth: .infinity)
                
                if workspace.isEmpty {
                    VStack(alignment: .center, spacing: 16) {
                        Text("Let's get started...").font(.headline).foregroundColor(.secondary)
                        Button(action: {}) {
                            Text("Create an empty page").fontWeight(.medium)
                        }
                        Button(action: {}) {
                            Text("Load example feeds").fontWeight(.medium)
                        }
                        Text("or").font(.headline).foregroundColor(.secondary)
                        Text("Import feeds from OPML\nin settings below")
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
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
                NavigationLink(destination: SettingsView(workspace: workspace)) {
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
                VStack {
                    Text("New Page Required").font(.title)
                    Text("Please create a page before subscribing to feeds.")
                }
            }
        }
    }
    
    func doneEditing() {
        self.editMode = .inactive
        self.saveContext()
    }
    
    func saveContext() {
        if self.viewContext.hasChanges {
            do {
                try self.viewContext.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
}
