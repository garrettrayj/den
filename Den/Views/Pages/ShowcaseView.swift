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

    var frameSize: CGSize

    var body: some View {
        ScrollView(.vertical) { content }
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
