//
//  BookmarksNavLink.swift
//  Den
//
//  Created by Garrett Johnson on 7/1/24.
//  Copyright © 2024 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftData
import SwiftUI

struct BookmarksNavLink: View {
    var body: some View {
        Label {
            Text("Bookmarks", comment: "Button label.")
        } icon: {
            Image(systemName: "bookmark")
        }
        .tag(DetailPanel.bookmarks)
        .accessibilityIdentifier("BookmarksNavLink")
    }
}
