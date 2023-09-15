//
//  ExpandedBookmarkPreview.swift
//  Den
//
//  Created by Garrett Johnson on 9/13/23.
//  Copyright © 2023 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

struct ExpandedBookmarkPreview: View {
    @Environment(\.isEnabled) private var isEnabled

    @ObservedObject var bookmark: Bookmark
    @ObservedObject var feed: Feed
    @ObservedObject var profile: Profile

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            FeedNavLink(feed: feed).buttonStyle(FeedTitleButtonStyle())
            Divider()
            BookmarkActionView(bookmark: bookmark, feed: feed, profile: profile) {
                VStack(alignment: .leading, spacing: 4) {
                    PreviewHeadline(title: bookmark.wrappedTitle)

                    if feed.hideBylines == false, let author = bookmark.author {
                        Text(author)
                            .font(.subheadline.weight(.medium))
                            .lineLimit(2)
                            .foregroundStyle(isEnabled ? .secondary : .tertiary)
                    }

                    PreviewDateAndAction(date: bookmark.date, browserView: feed.browserView)

                    if feed.hideImages != true, let url = bookmark.image {
                        PreviewImage(
                            url: url,
                            isRead: false,
                            width: CGFloat(bookmark.imageWidth),
                            height: CGFloat(bookmark.imageHeight)
                        ).padding(.top, 4)
                    }

                    if !feed.hideTeasers {
                        PreviewTeaser(teaser: bookmark.teaser!)
                    }
                }
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .topLeading)
                .padding()
            }
        }
        .modifier(RoundedContainerModifier())
    }
}
