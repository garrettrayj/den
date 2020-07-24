//
//  PageListView.swift
//  Den
//
//  Created by Garrett Johnson on 6/29/20.
//  Copyright © 2020 Garrett Johnson. All rights reserved.
//

import SwiftUI

/**
 Page list item view. Transforms name text labels into text fields when .editMode is active.
 */
struct PageListView: View {
    @Environment(\.managedObjectContext) var viewContext
    @Binding var editMode: EditMode
    @ObservedObject var workspace: Workspace
    @EnvironmentObject var updateCoordinator: UpdateCoordinator
    
    var body: some View {
        GeometryReader { geometry in
            RefreshableScrollView(refreshable: self.workspace, updateCoordinator: self.updateCoordinator) {
                List {
                    Section {
                        ForEach(self.workspace.pageArray) { page in
                            PageListRowView(page: page, workspace: self.workspace).environment(\.editMode, self.$editMode)
                        }
                        .onDelete(perform: self.delete)
                        .onMove(perform: self.move)
                    }
                }
                .frame(height: geometry.size.height)
                .environment(\.editMode, self.$editMode)
            }.background(Color(UIColor.secondarySystemBackground))
        }
    }
    
    func move(from source: IndexSet, to destination: Int) {
        workspace.mutableOrderedSetValue(forKeyPath: "pages").moveObjects(at: source, to: destination)
        
        if viewContext.hasChanges {
            do {
                try self.viewContext.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    func delete(indices: IndexSet) {
        workspace.pageArray.delete(at: indices, from: viewContext)
    }
}
struct PageListView_Previews: PreviewProvider {
    static var previews: some View {
        PageListView(editMode: .constant(.inactive), workspace: Workspace())
    }
}
