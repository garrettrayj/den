//
//  TagView.swift
//  Den
//
//  Created by Garrett Johnson on 9/12/23.
//  Copyright © 2023 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

struct TagView: View {
    @ObservedObject var tag: Tag
    
    @AppStorage("TagLayout") private var tagLayout: TagLayout = .previews

    var body: some View {
        if tag.managedObjectContext == nil || tag.isDeleted {
            ContentUnavailable {
                Label {
                    Text("Tag Deleted", comment: "Object removed message.")
                } icon: {
                    Image(systemName: "trash")
                }
            }
            .navigationTitle("")
        } else {
            WithBookmarks(scopeObject: tag) { bookmarks in
                if bookmarks.isEmpty {
                    ContentUnavailable {
                        Label {
                            Text("No Items", comment: "Content unavailable title.")
                        } icon: {
                            Image(systemName: "tag")
                        }
                    }
                } else if tagLayout == .list {
                    TagTableLayout(bookmarks: bookmarks)
                } else {
                    TagSpreadLayout(bookmarks: bookmarks)
                }
            }
            .navigationTitle(tag.displayName)
            .navigationTitle($tag.wrappedName)
            .toolbar {
                ToolbarTitleMenu {
                    RenameButton()
                    DeleteTagButton(tag: tag)
                }
                
                ToolbarItem {
                    TagLayoutPicker(tagLayout: $tagLayout)
                    #if os(macOS)
                    .pickerStyle(.inline)
                    #else
                    .pickerStyle(.menu)
                    .labelStyle(.iconOnly)
                    .padding(.trailing, -12)
                    #endif
                }
            }
        }
    }
}
