//
//  ShowcaseView.swift
//  Den
//
//  Created by Garrett Johnson on 2/11/22.
//  Copyright © 2022 Garrett Johnson. All rights reserved.
//

import SwiftUI

struct ShowcaseView: View {
    @ObservedObject var page: Page

    @Binding var hideRead: Bool
    @Binding var refreshing: Bool

    var frameSize: CGSize

    var body: some View {
        ScrollView(.vertical) {
            LazyVStack(alignment: .leading, spacing: 0, pinnedViews: .sectionHeaders) {
                ForEach(page.feedsArray) { feed in
                    if feed.feedData != nil {
                        ShowcaseSectionView(
                            feed: feed,
                            feedData: feed.feedData!,
                            hideRead: $hideRead,
                            refreshing: $refreshing,
                            width: frameSize.width
                        )
                    }
                }
            }
            .padding(.top, 8)
        }
    }
}
