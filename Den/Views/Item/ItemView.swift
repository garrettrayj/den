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
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @Environment(\.managedObjectContext) private var viewContext

    @ObservedObject var item: Item
    @ObservedObject var profile: Profile

    var maxContentWidth: CGFloat {
        CGFloat(700) * dynamicTypeSize.layoutScalingFactor
    }

    var body: some View {
        if item.managedObjectContext == nil || item.feedData?.feed == nil {
            ContentUnavailableView {
                Label {
                    Text("Item Deleted", comment: "Object removed message.")
                } icon: {
                    Image(systemName: "trash")
                }
            }
        } else {
            ArticleLayout(
                feed: item.feedData!.feed!,
                title: item.titleText,
                author: item.author,
                date: item.published,
                summaryContent: item.summary,
                bodyContent: item.body,
                link: item.link,
                image: item.image,
                imageWidth: CGFloat(item.imageWidth),
                imageHeight: CGFloat(item.imageHeight)
            )
            .background(.background)
            .toolbar { ItemToolbar(item: item, profile: profile) }
            .navigationTitle(Text(verbatim: ""))
            .onAppear {
                HistoryUtility.markItemRead(context: viewContext, item: item, profile: profile)
            }
        }
    }
}
