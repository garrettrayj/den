//
//  ShowcaseLayoutView.swift
//  Den
//
//  Created by Garrett Johnson on 3/15/23.
//  Copyright © 2023 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

struct ShowcaseLayoutView: View {
    @ObservedObject var page: Page
    
    @Binding var previewStyle: PreviewStyle
    
    let items: FetchedResults<Item>
    let width: CGFloat
    
    var body: some View {
        ScrollView(.vertical) {
            LazyVStack(alignment: .leading, spacing: 0, pinnedViews: .sectionHeaders) {
                ForEach(page.feedsArray) { feed in
                    ShowcaseSectionView(
                        feed: feed,
                        items: items.forFeed(feed: feed),
                        previewStyle: previewStyle,
                        width: width
                    )
                }
            }.padding(.bottom)
        }
    }
}
