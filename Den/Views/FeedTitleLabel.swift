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
    @Environment(\.isEnabled) private var isEnabled

    let title: String
    let favicon: URL?

    var read: Bool?

    var body: some View {
        Label {
            Text(title)
                .lineLimit(1)
                .foregroundColor(read == true || !isEnabled ? Color(.secondaryLabel) : Color(.label))
        } icon: {
            FeedFavicon(url: favicon)
                .opacity(read == true || !isEnabled ? AppDefaults.dimmedImageOpacity : 1.0)
        }
    }
}
