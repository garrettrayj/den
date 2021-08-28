//
//  PagesViewModel.swift
//  Den
//
//  Created by Garrett Johnson on 8/28/21.
//  Copyright © 2021 Garrett Johnson. All rights reserved.
//

import CoreData

final class PagesViewModel: ObservableObject {
    @Published var profile: Profile

    private var viewContext: NSManagedObjectContext
    private var crashManager: CrashManager

    init(profile: Profile, viewContext: NSManagedObjectContext, crashManager: CrashManager) {
        self.profile = profile
        self.viewContext = viewContext
        self.crashManager = crashManager
    }

    func createPage() {
        _ = Page.create(in: viewContext, profile: profile)
        do {
            try viewContext.save()
        } catch let error as NSError {
            crashManager.handleCriticalError(error)
        }
    }

    func movePage( from source: IndexSet, to destination: Int) {
        var revisedItems = profile.pagesArray

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
            } catch let error as NSError {
                crashManager.handleCriticalError(error)
            }
        }
    }

    func deletePage(indices: IndexSet) {
        profile.pagesArray.delete(at: indices, from: viewContext)
        profile.objectWillChange.send()
    }
}
