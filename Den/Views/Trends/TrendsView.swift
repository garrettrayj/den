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
    @EnvironmentObject private var refreshManager: RefreshManager

    @StateObject var viewModel: TrendsViewModel

    var body: some View {
        GeometryReader { geometry in
            ScrollView(.vertical) {
                BoardView(width: geometry.size.width, list: viewModel.trends) { trend in
                    TrendView(trend: trend)
                }
                .padding(.top, 8)
                .padding(.horizontal)
                .padding(.bottom)
            }
        }
        .onAppear {
            viewModel.analyzeTrends()
        }
        .toolbar {
            ToolbarItemGroup(placement: .bottomBar) {
                Spacer()
                VStack {
                    if viewModel.analyzing {
                        Text("Analyzing...")
                    } else {
                        Text("\(viewModel.trends.count) trends")
                    }
                }.font(.caption)
                Spacer()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(Color(UIColor.systemGroupedBackground).edgesIgnoringSafeArea(.all))
        .navigationTitle("Trends")
    }
}
