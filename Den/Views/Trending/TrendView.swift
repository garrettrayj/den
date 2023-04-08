//
//  TrendView.swift
//  Den
//
//  Created by Garrett Johnson on 7/2/22.
//  Copyright © 2022 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

struct TrendView: View {
    @ObservedObject var trend: Trend
    @ObservedObject var profile: Profile

    @Binding var refreshing: Bool
    @Binding var hideRead: Bool

    @AppStorage("TrendPreviewStyle_NoID") private var previewStyle: PreviewStyle = PreviewStyle.compressed

    init(
        trend: Trend,
        profile: Profile,
        refreshing: Binding<Bool>,
        hideRead: Binding<Bool>
    ) {
        self.trend = trend
        self.profile = profile

        _refreshing = refreshing
        _hideRead = hideRead

        _previewStyle = AppStorage(
            wrappedValue: PreviewStyle.compressed,
            "TrendPreviewStyle_\(profile.id?.uuidString ?? "NoID")"
        )
    }

    var body: some View {
        TrendLayout(trend: trend, profile: profile, hideRead: hideRead, previewStyle: previewStyle)
            .navigationTitle(trend.wrappedTitle)
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    PreviewStyleButton(previewStyle: $previewStyle)
                }
                ToolbarItem(placement: .bottomBar) {
                    TrendBottomBar(
                        trend: trend,
                        profile: profile,
                        refreshing: $refreshing,
                        hideRead: $hideRead
                    )
                }
            }
    }
}
