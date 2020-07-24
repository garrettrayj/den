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

    func close() {
        if viewContext.hasChanges {
            do {
                try  viewContext.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
        presentationMode.wrappedValue.dismiss()
    }
    
    func move(from source: IndexSet, to destination: Int) {
        page.mutableOrderedSetValue(forKeyPath: "feeds").moveObjects(at: source, to: destination)
    }
    
    func delete(indices: IndexSet) {
        page.feedArray.delete(at: indices, from: viewContext)
    }
        
    var body: some View {
        VStack(spacing: 0) {
            NavigationView {
                Form {
                    List {
                        ForEach(page.feedArray) { feed in
                            Text(feed.wrappedTitle)
                        }
                        .onMove(perform: move)
                        .onDelete(perform: delete)
                    }
                }
                .navigationBarTitle("Organize Feeds", displayMode: .inline)
                .navigationBarItems(leading: Button(action: close) { Text("Close") })
                .modifier(ModalNavigationBarModifier())
                .environment(\.editMode, .constant(.active))
            }.navigationViewStyle(StackNavigationViewStyle())
        }
    }
}

struct PageOrganizerView_Previews: PreviewProvider {
    static var previews: some View {
        PageOrganizerView(page: Page())
    }
}
