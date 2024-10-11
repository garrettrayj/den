//
//  ToggleBookmarkedButton.swift
//  Den
//
//  Created by Garrett Johnson on 7/14/24.
//  Copyright © 2024 Garrett Johnson. All rights reserved.
//

import SwiftUI

struct ToggleBookmarkedButton: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    @ObservedObject var item: Item
    
    var body: some View {
        Button {
            withAnimation {
                if item.bookmarked {
                    item.bookmarks.forEach { viewContext.delete($0) }
                    item.bookmarked = false
                } else {
                    _ = Bookmark.create(in: viewContext, item: item)
                    item.bookmarked = true
                }
                
                do {
                    try viewContext.save()
                } catch {
                    CrashUtility.handleCriticalError(error as NSError)
                }
            }
        } label: {
            Label {
                if item.bookmarked {
                    Text("Unbookmark", comment: "Button label.")
                } else {
                    Text("Bookmark", comment: "Button label.")
                }
            } icon: {
                Image(systemName: "bookmark").symbolVariant(item.bookmarked ? .slash : .none)
            }
        }
        .contentTransition(.symbolEffect(.replace))
        .accessibilityIdentifier("ToggleBookmarked")
        .help(Text("Bookmark/unbookmark", comment: "Button help text."))
    }
}
