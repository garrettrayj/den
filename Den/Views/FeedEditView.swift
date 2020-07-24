//
//  FeedEditView.swift
//  Den
//
//  Created by Garrett Johnson on 5/23/20.
//  Copyright © 2020 Garrett Johnson. All rights reserved.
//

import Foundation
import SwiftUI

/**
 FeedOptionsView wrapper for displaying options in a modal sheet.
 */
struct FeedEditView: View {
    @Environment(\.managedObjectContext) var viewContext
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var feed: Feed
    
    func close() {
        do {
            try viewContext.save()
            // Manually send objectWillChange for items in the feed to re-render with new settings
            feed.itemsArray.forEach { item in
                item.objectWillChange.send()
            }
        } catch {
            let nserror = error as NSError
            fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
        }
        presentationMode.wrappedValue.dismiss()
    }
    
    var body: some View {
        NavigationView {
            FeedOptionsView(
                feed: feed,
                onDelete: { self.presentationMode.wrappedValue.dismiss() },
                onMove: {
                    do {
                        try self.viewContext.save()
                    } catch {
                        let nserror = error as NSError
                        fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
                    }
                    self.presentationMode.wrappedValue.dismiss()
                }
            )
            .navigationBarItems(leading: Button(action: close) { Text("Close") })
            .modifier(ModalNavigationBarModifier())
        }.navigationViewStyle(StackNavigationViewStyle())
    }
}

struct ConfigView_Previews: PreviewProvider {
    static var previews: some View {
        FeedEditView(feed: Feed())
    }
}
