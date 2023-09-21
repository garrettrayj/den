//
//  BookmarkView.swift
//  Den
//
//  Created by Garrett Johnson on 9/13/23.
//  Copyright © 2023 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

struct BookmarkView: View {
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    @ObservedObject var bookmark: Bookmark

    var maxContentWidth: CGFloat {
        CGFloat(700) * dynamicTypeSize.layoutScalingFactor
    }

    var body: some View {
        if bookmark.managedObjectContext == nil || bookmark.feed == nil {
            ContentUnavailableView {
                Label {
                    Text("Bookmark Deleted", comment: "Object removed message.")
                } icon: {
                    Image(systemName: "trash")
                }
            }
        } else {
            ArticleLayout(
                feed: bookmark.feed!,
                title: bookmark.titleText,
                author: bookmark.author,
                date: bookmark.published,
                summaryContent: bookmark.summary,
                bodyContent: bookmark.body,
                link: bookmark.link,
                image: bookmark.image,
                imageWidth: CGFloat(bookmark.imageWidth),
                imageHeight: CGFloat(bookmark.imageHeight)
            )
            .background(.background)
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .navigationTitle(Text(verbatim: ""))
            .toolbar {
                BookmarkToolbar(bookmark: bookmark)
            }
        }
    }
}
