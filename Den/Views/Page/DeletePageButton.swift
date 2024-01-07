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
            page.feedsArray.forEach { feed in
                guard let feedData = feed.feedData else { return }
                viewContext.delete(feedData)
            }
            viewContext.delete(page)
            do {
                try viewContext.save()
            } catch {
                CrashUtility.handleCriticalError(error as NSError)
            }
        } label: {
            Label {
                Text("Delete", comment: "Button label.")
            } icon: {
                Image(systemName: "trash")
            }
            .symbolRenderingMode(.multicolor)
        }
        .buttonStyle(.borderless)
        .accessibilityIdentifier("DeletePage")
    }
}
