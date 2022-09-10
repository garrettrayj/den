//
//  ShowcaseView.swift
//  Den
//
//  Created by Garrett Johnson on 2/11/22.
//  Copyright © 2022 Garrett Johnson. All rights reserved.
//

import SwiftUI

struct ShowcaseView: View {
    let page: Page

    @Binding var hideRead: Bool
    @Binding var refreshing: Bool

    var frameSize: CGSize

    var body: some View {
        ScrollView(.vertical) {
            LazyVStack(alignment: .leading, spacing: 0, pinnedViews: .sectionHeaders) {
                ForEach(page.feedsArray) { feed in
                    ShowcaseSectionView(
                        feed: feed,
                        hideRead: $hideRead,
                        refreshing: $refreshing,
                        width: frameSize.width
                    )
                }
            }
        }
    }
}
