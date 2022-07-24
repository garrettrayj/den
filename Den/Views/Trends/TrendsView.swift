//
//  TrendsView.swift
//  Den
//
//  Created by Garrett Johnson on 7/1/22.
//  Copyright © 2022 Garrett Johnson. All rights reserved.
//

import CoreData
import SwiftUI

struct TrendsView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject private var crashManager: CrashManager
    @EnvironmentObject private var subscriptionManager: SubscriptionManager
    @EnvironmentObject private var linkManager: LinkManager
    @EnvironmentObject private var profileManager: ProfileManager

    @ObservedObject var viewModel: TrendsViewModel

    #if targetEnvironment(macCatalyst)
    let emptyCaption = Text("""
    Add feeds by opening syndication links \
    or click \(Image(systemName: "plus.circle")) to add by web address
    """)
    #else
    let emptyCaption = Text("""
    Add feeds by opening syndication links \
    or tap \(Image(systemName: "ellipsis.circle")) then \(Image(systemName: "plus.circle")) \
    to add by web address
    """)
    #endif

    var body: some View {
        VStack {
            if viewModel.profile.feedsArray.isEmpty {
                StatusBoxView(
                    message: Text("Page Empty"),
                    caption: emptyCaption,
                    symbol: "questionmark.square.dashed"
                )
            } else {
                GeometryReader { geometry in
                    ScrollView(.vertical) {
                        Group {
                            if viewModel.profile.trends.isEmpty {
                                StatusBoxView(
                                    message: Text("No Items"),
                                    caption: Text("Tap \(Image(systemName: "arrow.clockwise")) to refresh"),
                                    symbol: "questionmark.square.dashed"
                                )
                                .frame(height: geometry.size.height - 60)
                            } else {
                                BoardView(width: geometry.size.width, list: viewModel.profile.trends) { trend in
                                    TrendBlockView(trend: trend)
                                }
                                .padding(.horizontal)
                                .padding(.bottom)
                            }
                        }.padding(.top, 8)
                    }
                }
            }
        }
        .background(Color(UIColor.systemGroupedBackground))
        .navigationTitle("Trends")
        .navigationBarTitleDisplayMode(.large)
    }
}
