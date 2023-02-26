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

    var read: Bool?

    var body: some View {
        Label {
            Text(title).lineLimit(1).foregroundColor(read == true || !isEnabled ? .secondary : .primary)
        } icon: {
            FeedFaviconView(url: favicon)
                .opacity(read == true || !isEnabled ? UIConstants.dimmedImageOpacity : 1.0)
        }
    }
}
