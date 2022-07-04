//
//  PageTrendsView.swift
//  Den
//
//  Created by Garrett Johnson on 7/4/22.
//  Copyright © 2022 Garrett Johnson. All rights reserved.
//

import SwiftUI

struct PageTrendsView: View {
    @EnvironmentObject private var refreshManager: RefreshManager
    @EnvironmentObject private var profileManager: ProfileManager

    @ObservedObject var page: Page

    var frameSize: CGSize

    var body: some View {
        ScrollView(.vertical) { content }
    }

    @ViewBuilder
    var content: some View {
        if page.trends().isEmpty {
            StatusBoxView(
                message: Text("No Items"),
                caption: Text("Tap \(Image(systemName: "arrow.clockwise")) to refresh"),
                symbol: "questionmark.square.dashed"
            )
            .frame(height: frameSize.height - 60)
        } else {
            BoardView(width: frameSize.width, list: page.trends()) { trend in
                TrendView(trend: trend)
            }
            .padding(.horizontal)
            .padding(.bottom)
        }
    }
}
