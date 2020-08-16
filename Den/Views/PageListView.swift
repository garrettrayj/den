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
    @ObservedObject var updateManager: UpdateManager
    
    var body: some View {
        GeometryReader { geometry in
            
            if self.editMode == EditMode.active {
                List {
                    ForEach(self.workspace.pagesArray) { page in
                        PageListRowView(page: page, workspace: self.workspace).environment(\.editMode, self.$editMode).allowsHitTesting(false)
                    }
                    .onMove(perform: self.move)
                    .onDelete(perform: self.delete)
                    // Defined to workaround fatal error because of missing insert action while moving. Probably a SwiftUI bug.
                    .onInsert(of: [String()], perform: self.insert(at:itemProvider:))
                }
                .frame(height: geometry.size.height)
                .environment(\.editMode, self.$editMode)
            } else {
                RefreshableScrollView(updateManager: self.updateManager) {
                    List {
                        ForEach(self.workspace.pagesArray) { page in
                            PageListRowView(page: page, workspace: self.workspace).environment(\.editMode, self.$editMode).allowsHitTesting(false)
                        }
                    }
                    .frame(height: geometry.size.height)
                }.background(Color(UIColor.secondarySystemBackground))
            }
            
            
        }
    }
    
    func move(from sources: IndexSet, to destination: Int) {
        let source = sources.first!
        if destination > source {
            workspace.mutableOrderedSetValue(forKey: "pages").moveObjects(at: sources, to: destination - 1)
        } else if destination < source {
            workspace.mutableOrderedSetValue(forKey: "pages").moveObjects(at: sources, to: destination)
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
        workspace.pagesArray.delete(at: indices, from: viewContext)
    }
    
    func insert(at offset: Int, itemProvider: [NSItemProvider]) {
        print("Page list insert action not available")
    }
}
