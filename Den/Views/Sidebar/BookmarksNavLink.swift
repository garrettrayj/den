//
//  BookmarksNavLink.swift
//  Den
//
//  Created by Garrett Johnson on 7/14/24.
//  Copyright © 2024 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import CoreData
import SwiftUI

struct BookmarksNavLink: View {
    @Environment(\.managedObjectContext) private var viewContext

    var body: some View {
        Label {
            Text("Bookmarks", comment: "Button label.")
        } icon: {
            Image(systemName: "book")
        }
        .tag(DetailPanel.bookmarks)
        .onDrop(
            of: [.denItem],
            delegate: BookmarksNavDropDelegate(context: viewContext)
        )
        .accessibilityIdentifier("BookmarksNavLink")
    }
}
