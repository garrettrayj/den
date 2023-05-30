//
//  FeedTitleLabel.swift
//  Den
//
//  Created by Garrett Johnson on 8/23/21.
//  Copyright © 2021 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

struct FeedTitleLabel: View {
    let title: Text?
    let favicon: URL?

    var body: some View {
        Label {
            title ?? Text("Untitled")
        } icon: {
            FeedFavicon(url: favicon)
        }
        .lineLimit(1)
    }
}
