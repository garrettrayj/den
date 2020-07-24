//
//  WorkspaceView.swift
//  Den
//
//  Created by Garrett Johnson on 5/18/20.
//  Copyright © 2020 Garrett Johnson. All rights reserved.
//

import SwiftUI

private let dateFormatter: DateFormatter = {
    let dateFormatter = DateFormatter()
    dateFormatter.dateStyle = .medium
    dateFormatter.timeStyle = .medium
    return dateFormatter
}()

/**
 Master navigation list with links to Pages. Activating editMode enables Page CRUD and ordering.
*/
struct WorkspaceView: View {
    @Environment(\.managedObjectContext) var viewContext
    @ObservedObject var workspace: Workspace
    @State var editMode: EditMode = .inactive

    var workspaceIsEmpty: Bool {
        workspace.pageArray.count == 0
    }
    
    var body: some View {
        VStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 0) {
                VStack(alignment: .center) {
                    Image("TitleIcon").resizable().scaledToFit().frame(width: 48, height: 48)
                    Text("Den").font(.title).fontWeight(.semibold)
                }.padding(.top, -82).padding(.horizontal, 8).padding(.bottom).frame(maxWidth: .infinity)
                
                if workspaceIsEmpty {
                    VStack(alignment: .center, spacing: 16) {
                        Text("Let's get started").font(.headline).foregroundColor(.secondary)
                        Button(action: {}) {
                            Text("Create an empty page").padding()
                        }.overlay(
                            RoundedRectangle(cornerRadius: 4).stroke(Color.accentColor, lineWidth: 1)
                        )
                        Button(action: {}) {
                            Text("Load example feeds").padding()
                        }.overlay(
                            RoundedRectangle(cornerRadius: 4).stroke(Color.accentColor, lineWidth: 1)
                        )
                        Text("or").foregroundColor(.secondary).fontWeight(.medium)
                        Text("Import feeds in settings below").foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                    }.padding(.top).frame(maxWidth: .infinity)
                    Spacer()
                } else {
                    PageListView(editMode: self.$editMode, workspace: self.workspace)
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
                if !workspaceIsEmpty {
                    if self.editMode == .active {
                        Button(action: doneEditing) {
                            Text("Done")
                        }
                    } else {
                        Button(action: { self.editMode = .active }) {
                            Text("Edit")
                        }
                    }
                }
            },
            trailing: HStack {
                if !workspaceIsEmpty {
                    if self.editMode == .active {
                        Button(action: { withAnimation { let _ = Page.create(in: self.viewContext, workspace: self.workspace) }}) {
                            Image(systemName: "plus")
                        }
                    } else {
                        Button(action: refreshFeeds) {
                            Image(systemName: "arrow.clockwise")
                        }
                    }
                }
            }
        )
    }
    
    func refreshFeeds() {
        var feedsForUpdate: Array<Feed> = []
        workspace.pageArray.forEach { page in
            feedsForUpdate.append(contentsOf: page.feedArray)
        }
        
        DispatchQueue.global(qos: .userInitiated).async {
            //let feedUpdater = FeedUpdater(feeds: feedsForUpdate)
            //feedUpdater.start()
            
            do {
                try self.viewContext.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
            
            DispatchQueue.main.async {
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

struct WorkspaceView_Previews: PreviewProvider {
    static var previews: some View {
        WorkspaceView(workspace: Workspace())
    }
}
