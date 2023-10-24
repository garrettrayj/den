//
//  TagsMenu.swift
//  Den
//
//  Created by Garrett Johnson on 9/12/23.
//  Copyright © 2023 Garrett Johnson
//

import SwiftUI

struct TagsMenu: View {
    @Environment(\.managedObjectContext) private var viewContext

    @ObservedObject var item: Item
    @ObservedObject var profile: Profile

    var body: some View {
        Menu {
            if profile.tagsArray.isEmpty {
                Text("No Tags", comment: "Menu options unavailable message.")
            }
            ForEach(profile.tagsArray) { tag in
                if item.bookmarkTags.contains(tag) {
                    Button {
                        for bookmark in item.bookmarks where bookmark.tag == tag {
                            viewContext.delete(bookmark)
                        }
                        do {
                            try viewContext.save()
                            item.objectWillChange.send()
                            profile.objectWillChange.send()
                        } catch {
                            CrashUtility.handleCriticalError(error as NSError)
                        }
                    } label: {
                        Label { tag.nameText } icon: {
                            Image(systemName: "tag.fill")
                        }
                    }
                    .labelStyle(.titleAndIcon)
                    .accessibilityIdentifier("RemoveBookmark")
                } else {
                    Button {
                        _ = Bookmark.create(in: viewContext, item: item, tag: tag)
                        do {
                            try viewContext.save()
                            item.objectWillChange.send()
                            profile.objectWillChange.send()
                        } catch {
                            CrashUtility.handleCriticalError(error as NSError)
                        }
                    } label: {
                        Label { tag.nameText } icon: {
                            Image(systemName: "tag")
                        }
                    }
                    .labelStyle(.titleAndIcon)
                    .accessibilityIdentifier("AddBookmark")
                }
            }
        } label: {
            Label {
                Text("Bookmark", comment: "Menu label.")
            } icon: {
                if item.bookmarks.count > 0 {
                    Image(systemName: "bookmark.fill")
                } else {
                    Image(systemName: "bookmark")
                }
            }
        }
        .menuIndicator(.hidden)
    }
}
