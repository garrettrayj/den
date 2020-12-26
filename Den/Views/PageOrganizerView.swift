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
    @State var movingItem: Bool = false

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Settings")) {
                    HStack {
                        Text("Title")
                        TextField("Title", text: $page.wrappedName).multilineTextAlignment(.trailing)
                    }
                    
                    Stepper("Max Items Per Feed: \(page.itemsPerFeed)", value: $page.itemsPerFeed, in: 1...Int16.max)
                }
                
                Section(header: HStack { Text("\(page.feedsArray.count) FEEDS"); Spacer(); Text("DRAG TO REORDER") }) {
                    List {
                        ForEach(page.feedsArray) { feed in
                            Text(feed.wrappedTitle)
                        }
                        .onDelete(perform: delete)
                        .onMove(perform: move)
                        .onInsert(of: [], perform: insert)
                    }
                }
            }
            .navigationBarTitle("Organizer Feeds", displayMode: .inline)
            .navigationBarItems(leading: Button(action: { self.presentationMode.wrappedValue.dismiss() }) { Text("Close") })
            .environment(\.editMode, .constant(.active))
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .onDisappear {
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
    
    func delete(indices: IndexSet) {
        page.feedsArray.delete(at: indices, from: viewContext)
    }
    
    private func move( from source: IndexSet, to destination: Int) {
        // Make an array of items from fetched results
        var revisedItems: [Feed] = page.feedsArray.map { $0 }

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
    
    func insert(at offset: Int, itemProviders: [NSItemProvider]) {
        print("Page list insert action not available")
    }
}
