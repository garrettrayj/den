//
//  BlendItemView.swift
//  Den
//
//  Created by Garrett Johnson on 1/28/22.
//  Copyright © 2022 Garrett Johnson. All rights reserved.
//

import SwiftUI

struct BlendItemView: View {
    @Environment(\.managedObjectContext) var viewContext
    @EnvironmentObject private var crashManager: CrashManager
    @EnvironmentObject private var refreshManager: RefreshManager

    var item: Item

    var body: some View {
        if item.feedData?.feed != nil {
            VStack(alignment: .leading, spacing: 0) {
                NavigationLink {
                    FeedView(viewModel: FeedViewModel(
                        viewContext: viewContext,
                        crashManager: crashManager,
                        feed: item.feedData!.feed!,
                        refreshing: false
                    ))
                } label: {
                    HStack {
                        FeedTitleLabelView(
                            title: item.feedData?.feed?.wrappedTitle ?? "Untitled",
                            faviconImage: item.feedData?.faviconImage
                        )
                        Spacer()
                        NavChevronView()
                    }.padding(.horizontal, 12)
                }
                .buttonStyle(FeedTitleButtonStyle())
                .disabled(refreshManager.isRefreshing)
                .accessibilityIdentifier("item-feed-button")

                Divider()

                ItemPreviewView(item: item)
            }
            .modifier(GroupBlockModifier())
        }
    }
}
