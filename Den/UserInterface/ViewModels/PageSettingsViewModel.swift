//
//  PageSettingsViewModel.swift
//  Den
//
//  Created by Garrett Johnson on 2/16/22.
//  Copyright © 2022 Garrett Johnson. All rights reserved.
//

import Combine
import CoreData
import SwiftUI

class PageSettingsViewModel: ObservableObject {
    let viewContext: NSManagedObjectContext
    let crashManager: CrashManager

    @Published var page: Page
    @Published var showingIconPicker: Bool = false
    @Published var showingDeleteAlert: Bool = false

    init(viewContext: NSManagedObjectContext, crashManager: CrashManager, page: Page) {
        self.viewContext = viewContext
        self.crashManager = crashManager
        self.page = page
    }

    func save() {
        if viewContext.hasChanges {
            do {
                try viewContext.save()
                NotificationCenter.default.post(name: .pageRefreshed, object: page.objectID)
            } catch {
                crashManager.handleCriticalError(error as NSError)
            }
        }
    }

    func deleteFeed(indices: IndexSet) {
        indices.forEach { viewContext.delete(page.feedsArray[$0]) }

        do {
            try viewContext.save()
            NotificationCenter.default.post(name: .pageRefreshed, object: page.objectID)
        } catch {
            crashManager.handleCriticalError(error as NSError)
        }
    }

    func moveFeed( from source: IndexSet, to destination: Int) {
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
    }
}
