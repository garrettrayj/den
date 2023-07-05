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

    var maxContentWidth: CGFloat {
        CGFloat(700) * dynamicTypeSize.layoutScalingFactor
    }

    var body: some View {
        if item.managedObjectContext == nil || item.feedData?.feed == nil {
            SplashNote(title: Text("Item Deleted", comment: "Object removed message."))
        } else {
            itemLayout
                .background(.background)
                .toolbar { ItemToolbar(item: item) }
                #if os(iOS)
                .navigationBarTitleDisplayMode(.inline)
                #endif
                .navigationTitle(Text(verbatim: ""))
        }
    }

    private var itemLayout: some View {
        GeometryReader { _ in
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
                                html: item.body ?? item.summary!,
                                title: item.wrappedTitle,
                                baseURL: item.link
                            )
                        }
                    }
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: maxContentWidth)
                }
                .frame(maxWidth: .infinity)
                .padding(.horizontal)
                .padding(.vertical, 24)
                .task { await HistoryUtility.markItemRead(item: item) }
            }
        }
    }
}
