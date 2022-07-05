//
//  GlobalShowcaseView.swift
//  Den
//
//  Created by Garrett Johnson on 7/4/22.
//  Copyright © 2022 Garrett Johnson. All rights reserved.
//

import SwiftUI

struct GlobalShowcaseView: View {
    @ObservedObject var profile: Profile

    @Binding var hideRead: Bool

    var frameSize: CGSize

    var body: some View {
        LazyVStack(alignment: .leading, spacing: 0, pinnedViews: .sectionHeaders) {
            ForEach(profile.feedsArray) { feed in
                ShowcaseSectionView(
                    feed: feed,
                    hideRead: $hideRead,
                    width: frameSize.width
                )
            }
        }
    }
}
