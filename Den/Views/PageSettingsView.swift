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
struct PageSettingsView: View {
    @Environment(\.managedObjectContext) var viewContext
    @EnvironmentObject var refreshManager: RefreshManager
    @EnvironmentObject var crashManager: CrashManager
    
    @ObservedObject var mainViewModel: MainViewModel
    
    @State var itemsPerFeedStepperValue: Int = 0
    @State var pageNameText: String = ""

    var body: some View {
        if mainViewModel.activePage == nil {
            Text("Page Settings Unavailable")
        } else {
            NavigationView {
                Form {
                    Section(header: Text("Settings")) {
                        HStack {
                            Text("Name")
                            TextField("Name", text: $pageNameText).multilineTextAlignment(.trailing)
                        }
                        
                        Stepper("Feed Item Limit: \(itemsPerFeedStepperValue)", value: $itemsPerFeedStepperValue, in: 1...Int(Int16.max))
                    }
                    
                    Section(header: HStack { Text("\(mainViewModel.activePage!.subscriptionsArray.count) Feeds"); Spacer(); Text("Drag to Reorder") }) {
                        List {
                            ForEach(mainViewModel.activePage!.subscriptionsArray) { subscription in
                                Text(subscription.wrappedTitle)
                            }
                            .onDelete(perform: delete)
                            .onMove(perform: move)
                        }.environment(\.editMode, .constant(.active))
                    }
                }
                .navigationTitle("Page Settings")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar() {
                    ToolbarItem() {
                        Button(action: close) { Text("Close") }
                    }
                }
                .environment(\.editMode, .constant(.active))
            }
            .navigationViewStyle(StackNavigationViewStyle())
            .onAppear(perform: load)
            .onDisappear(perform: save)
        }
    }
    
    func close() {
        self.mainViewModel.showingPageSheet = false
    }
    
    func load() {
        guard let page = mainViewModel.activePage else { return }
        
        itemsPerFeedStepperValue = page.wrappedItemsPerFeed
        pageNameText = page.wrappedName
    }
    
    func save() {
        guard let page = mainViewModel.activePage else { return }

        var refresh = false
        
        if itemsPerFeedStepperValue != page.wrappedItemsPerFeed {
            page.wrappedItemsPerFeed = itemsPerFeedStepperValue
            refresh = true
        }
        
        if pageNameText != page.wrappedName {
            page.wrappedName = pageNameText
        }
        
        if self.viewContext.hasChanges {
            do {
                try viewContext.save()
                
                if refresh == true {
                    self.refreshManager.refresh(page)
                }
            } catch let error as NSError {
                crashManager.handleCriticalError(error)
            }
        }
    }
    
    func delete(indices: IndexSet) {
        if mainViewModel.activePage == nil { return }
        
        mainViewModel.activePage!.subscriptionsArray.delete(at: indices, from: viewContext)
    }
    
    private func move( from source: IndexSet, to destination: Int) {
        if mainViewModel.activePage == nil { return }
        
        // Make an array of items from fetched results
        var revisedItems: [Subscription] = mainViewModel.activePage!.subscriptionsArray.map { $0 }

        // change the order of the items in the array
        revisedItems.move(fromOffsets: source, toOffset: destination)

        // update the userOrder attribute in revisedItems to
        // persist the new order. This is done in reverse order
        // to minimize changes to the indices.
        for reverseIndex in stride(from: revisedItems.count - 1, through: 0, by: -1 ) {
            revisedItems[reverseIndex].userOrder = Int16(reverseIndex)
        }
    }
}
