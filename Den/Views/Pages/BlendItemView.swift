//
//  BlendItemView.swift
//  Den
//
//  Created by Garrett Johnson on 1/28/22.
//  Copyright © 2022 Garrett Johnson. All rights reserved.
//

import SwiftUI

struct BlendItemView: View {
    @EnvironmentObject var refreshManager: RefreshManager
    @EnvironmentObject var linkManager: LinkManager

    @ObservedObject var item: Item

    var feedViewModel: FeedViewModel?

    var body: some View {
        if feedViewModel != nil {
            VStack(alignment: .leading, spacing: 0) {
                NavigationLink {
                    FeedView(viewModel: feedViewModel!)
                } label: {
                    FeedTitleLabelView(
                        title: feedViewModel!.feed.wrappedTitle,
                        faviconImage: feedViewModel!.feed.feedData?.faviconImage
                    )
                }
                .buttonStyle(FeedTitleButtonStyle())
                .disabled(refreshManager.isRefreshing)
                .frame(height: 32, alignment: .leading)
                .padding(.horizontal, 12)

                Divider()

                ItemPreviewView(item: item).padding(.top, 12)
            }
            .modifier(GroupBlockModifier())
        }
    }
}
