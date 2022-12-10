//
//  FeedTitleLabelView.swift
//  Den
//
//  Created by Garrett Johnson on 8/23/21.
//  Copyright © 2021 Garrett Johnson. All rights reserved.
//

import SwiftUI

struct FeedTitleLabelView: View {
    @Environment(\.isEnabled) private var isEnabled

    let title: String
    let favicon: URL?

    var dimmed: Bool = false

    var body: some View {
        Label {
            Text(title).lineLimit(1)
                .foregroundColor(
                    isEnabled ?
                        dimmed ? .secondary : .primary
                    :
                        Color(UIColor.tertiaryLabel)
                )
        } icon: {
            FeedFaviconView(url: favicon, dimmed: dimmed)
        }
    }
}
