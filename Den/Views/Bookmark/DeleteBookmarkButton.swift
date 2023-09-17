//
//  DeleteBookmarkButton.swift
//  Den
//
//  Created by Garrett Johnson on 9/17/23.
//  Copyright © 2023 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

struct DeleteBookmarkButton: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.managedObjectContext) private var viewContext

    @ObservedObject var bookmark: Bookmark

    var body: some View {
        Button(role: .destructive) {
            guard let tag = bookmark.tag else { return }
            viewContext.delete(bookmark)
            do {
                try viewContext.save()
                tag.objectWillChange.send()
            } catch {
                CrashUtility.handleCriticalError(error as NSError)
            }
        } label: {
            Label {
                Text("Delete Bookmark")
            } icon: {
                Image(systemName: "bookmark.slash")
            }
        }
    }
}
