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
        VStack(spacing: 0) {
            NavigationView {
                Form {
                    List() {
                        ForEach(page.feedsArray) { feed in
                            Text(feed.wrappedTitle)
                        }
                        .onDelete(perform: delete)
                        .onMove(perform: move)
                    }
                }
                .navigationBarTitle("Organize Feeds", displayMode: .inline)
                .navigationBarItems(leading: Button(action: close) { Text("Close") })
                .modifier(ModalNavigationBarModifier())
                .environment(\.editMode, .constant(.active))
            }.navigationViewStyle(StackNavigationViewStyle())
        }.onDisappear {
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
    
    func close() {
        presentationMode.wrappedValue.dismiss()
    }
    
    func delete(indices: IndexSet) {
        page.feedsArray.delete(at: indices, from: viewContext)
    }
    
    func move(from sources: IndexSet, to destination: Int) {
        page.feedsArray.move(fromOffsets: sources, toOffset: destination)
        page.objectWillChange.send()
    }
}
