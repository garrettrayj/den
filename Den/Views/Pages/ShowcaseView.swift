//
//  ShowcaseView.swift
//  Den
//
//  Created by Garrett Johnson on 2/11/22.
//  Copyright © 2022 Garrett Johnson. All rights reserved.
//

import SwiftUI

struct ShowcaseView: View {
    @EnvironmentObject private var refreshManager: RefreshManager

    @ObservedObject var page: Page

    var frameSize: CGSize

    var body: some View {
        #if targetEnvironment(macCatalyst)
        ScrollView(.vertical) { content }
        #else
        RefreshableScrollView(
            onRefresh: { done in
                refreshManager.refresh(page: page)
                done()
            },
            content: { content }
        )
        #endif
    }

    var content: some View {
        LazyVStack(alignment: .leading, spacing: 0, pinnedViews: .sectionHeaders) {
            ForEach(page.feedsArray) { feed in
                ShowcaseSectionView(
                    feed: feed,
                    width: frameSize.width
                )
            }
        }
        .padding(.top, 8)
        .padding(.bottom, 22)
    }
}
