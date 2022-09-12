//
//  FeedTitleLabelView.swift
//  Den
//
//  Created by Garrett Johnson on 8/23/21.
//  Copyright © 2021 Garrett Johnson. All rights reserved.
//

import SwiftUI

struct FeedTitleLabelView: View {
    let title: String
    let favicon: URL?

    var body: some View {
        Label {
            Text(title).lineLimit(1)
        } icon: {
            FeedFaviconView(url: favicon)
        }
    }
}
