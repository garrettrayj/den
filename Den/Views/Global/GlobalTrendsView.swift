//
//  GlobalTrendsView.swift
//  Den
//
//  Created by Garrett Johnson on 7/1/22.
//  Copyright © 2022 Garrett Johnson. All rights reserved.
//

import CoreData
import SwiftUI

struct GlobalTrendsView: View {
    @EnvironmentObject private var refreshManager: RefreshManager
    @EnvironmentObject private var profileManager: ProfileManager

    @ObservedObject var profile: Profile

    var frameSize: CGSize

    var body: some View {
        if profile.trends().isEmpty {
            StatusBoxView(
                message: Text("No Items"),
                caption: Text("Tap \(Image(systemName: "arrow.clockwise")) to refresh"),
                symbol: "questionmark.square.dashed"
            )
            .frame(height: frameSize.height - 60)
        } else {
            BoardView(width: frameSize.width, list: profile.trends()) { trend in
                TrendBlockView(trend: trend)
            }
            .padding(.horizontal)
            .padding(.bottom)
        }
    }
}
