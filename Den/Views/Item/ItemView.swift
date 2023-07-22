//
//  ItemView.swift
//  Den
//
//  Created by Garrett Johnson on 7/8/22.
//  Copyright © 2022 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

struct ItemView: View {
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    @ObservedObject var item: Item
    @ObservedObject var profile: Profile

    var maxContentWidth: CGFloat {
        CGFloat(700) * dynamicTypeSize.layoutScalingFactor
    }

    var body: some View {
        if item.managedObjectContext == nil || item.feedData?.feed == nil {
            SplashNote(Text("Item Deleted", comment: "Object removed message."))
        } else {
            itemLayout
                .background(.background)
                .toolbar(id: "Item") { ItemToolbar(item: item, profile: profile) }
                #if os(iOS)
                .navigationBarTitleDisplayMode(.inline)
                #endif
                .navigationTitle(Text(verbatim: ""))
                .task { await HistoryUtility.markItemRead(item: item) }
        }
    }

    private var itemLayout: some View {
        ScrollView(.vertical) {
            VStack {
                VStack(alignment: .leading, spacing: 16) {
                    FeedTitleLabel(feed: item.feedData!.feed!)
                        .font(.title3)
                        .textSelection(.enabled)

                    VStack(alignment: .leading, spacing: 4) {
                        Text(item.wrappedTitle)
                            .font(.largeTitle.weight(.semibold))
                            .textSelection(.enabled)
                            .fixedSize(horizontal: false, vertical: true)
                            .padding(.bottom, 4)

                        if let author = item.author {
                            Text(author).font(.callout).lineLimit(2)
                        }

                        TimelineView(.everyMinute) { _ in
                            HStack(spacing: 4) {
                                Text(verbatim: item.date.formatted(date: .complete, time: .shortened))
                                Text(verbatim: "(\(item.date.formatted(.relative(presentation: .numeric))))")
                            }.font(.caption2)
                        }
                    }

                    if
                        item.image != nil &&
                        !(item.summary?.contains("<img") ?? false) &&
                        !(item.body?.contains("<img") ?? false)
                    {
                        ItemHero(item: item)
                    }

                    if item.body != nil || item.summary != nil {
                        ItemWebView(
                            content: item.body ?? item.summary!,
                            title: item.wrappedTitle,
                            baseURL: item.link,
                            tintColor: profile.tintColor
                        )
                    }
                }
                .multilineTextAlignment(.leading)
                .frame(maxWidth: maxContentWidth)
            }
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 32)
            .padding(.vertical, 28)
        }
    }
}
