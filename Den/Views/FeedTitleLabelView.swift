//
//  FeedTitleLabelView.swift
//  Den
//
//  Created by Garrett Johnson on 8/23/21.
//  Copyright © 2021 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

struct FeedTitleLabelView: View {
    @Environment(\.isEnabled) private var isEnabled

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
