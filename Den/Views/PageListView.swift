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

    var pages: FetchedResults<Page>
    
    var body: some View {
        List {
            ForEach(self.pages) { page in
                PageListEditRowView(page: page)
            }
            .onMove(perform: self.move)
            .onDelete(perform: self.delete)
        }
        .listStyle(SidebarListStyle())
        .environment(\.editMode, self.$editMode)
        
        
        
        GeometryReader { geometry in
            if self.editMode == EditMode.active {
                List {
                    ForEach(self.pages) { page in
                        PageListEditRowView(page: page)
                    }
                    .onMove(perform: self.move)
                    .onDelete(perform: self.delete)
                    // Defined to workaround fatal error because of missing insert action while moving. Probably a SwiftUI bug.
                }
                .listStyle(SidebarListStyle())
                .environment(\.editMode, self.$editMode)
            } else {
                RefreshableScrollView(refreshables: self.pages.map { $0 }) {
                    List {
                        ForEach(self.pages) { page in
                            PageListRowView(page: page, editMode: $editMode)
                        }.listRowInsets(.init(top: 0, leading: 16, bottom: 0, trailing: 16))
                    }
                    .navigationTitle("Den")
                }.background(Color(UIColor.secondarySystemBackground))
            }
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
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    func delete(indices: IndexSet) {
        pages.delete(at: indices, from: viewContext)
    }
    
    func onInsert(at offset: Int, itemProvider: [NSItemProvider]) {
        print("Page list insert action not available")
    }
}
