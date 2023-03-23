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
    let title: String
    let favicon: URL?

    var read: Bool?

    var body: some View {
        Label {
            Text(title).lineLimit(1)
        } icon: {
            FeedFavicon(url: favicon)
        }
    }
}
