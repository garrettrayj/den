//
//  DeletePageButton.swift
//  Den
//
//  Created by Garrett Johnson on 9/18/23.
//  Copyright © 2023 Garrett Johnson
//

import SwiftUI

struct DeletePageButton: View {
    @Environment(\.managedObjectContext) private var viewContext

    @ObservedObject var page: Page

    var body: some View {
        Button(role: .destructive) {
            // Deleting feed data before page deletion task to work around crash problem
            page.feedsArray.compactMap { $0.feedData }.forEach { viewContext.delete($0) }
            
            Task {
                viewContext.delete(page)

                do {
                    try viewContext.save()
                } catch {
                    CrashUtility.handleCriticalError(error as NSError)
                }
            }
        } label: {
            DeleteLabel()
        }
        .accessibilityIdentifier("DeletePage")
    }
}
