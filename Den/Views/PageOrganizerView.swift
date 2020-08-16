//
//  PageOrganizerView.swift
//  Den
//
//  Created by Garrett Johnson on 5/21/20.
//  Copyright © 2020 Garrett Johnson. All rights reserved.
//

import SwiftUI

/**
 User interface for reordering, moving, and deleting Gadgets within a Page
 */
struct PageOrganizerView: View {
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.managedObjectContext) var viewContext
    @ObservedObject var page: Page

    var body: some View {
        VStack(spacing: 0) {
            NavigationView {
                Form {
                    List {
                        ForEach(page.feedsArray) { feed in
                            Text(feed.wrappedTitle)
                        }
                        .onMove(perform: move)
                        .onDelete(perform: delete)
                        .onInsert(of: [String()], perform: self.insert(at:itemProvider:))
                    }
                }
                .navigationBarTitle("Organize Feeds", displayMode: .inline)
                .navigationBarItems(leading: Button(action: close) { Text("Close") })
                .modifier(ModalNavigationBarModifier())
                .environment(\.editMode, .constant(.active))
            }.navigationViewStyle(StackNavigationViewStyle())
        }
    }
    
    func close() {
        presentationMode.wrappedValue.dismiss()
    }
    
    func delete(indices: IndexSet) {
        page.feedsArray.delete(at: indices, from: viewContext)
    }
    
    func move(from sources: IndexSet, to destination: Int) {
        let source = sources.first!
        if destination > source {
            page.mutableOrderedSetValue(forKey: "feeds").moveObjects(at: sources, to: destination - 1)
        } else if destination < source {
            page.mutableOrderedSetValue(forKey: "feeds").moveObjects(at: sources, to: destination)
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
    
    func insert(at offset: Int, itemProvider: [NSItemProvider]) {
        print("Page list insert action not available")
    }
}
