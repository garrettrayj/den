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

    @ObservedObject var viewModel: TrendsViewModel

    var body: some View {
        GeometryReader { geometry in
            if viewModel.profile.trends.isEmpty {
                StatusBoxView(
                    message: Text("Trends Empty"),
                    caption: Text("Item titles do not share any common subjects"),
                    symbol: "questionmark.folder"
                )
                .frame(height: geometry.size.height - 60)
            } else {
                ScrollView(.vertical) {
                    BoardView(width: geometry.size.width, list: viewModel.profile.trends) { trend in
                        TrendBlockView(trend: trend)
                    }
                    .padding(.horizontal)
                    .padding(.bottom)
                    .padding(.top, 8)
                }
            }
        }
        .background(Color(UIColor.systemGroupedBackground))
        .navigationTitle("Trends")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItemGroup(placement: .bottomBar) {
                Text("\(viewModel.profile.trends.count) trends").font(.caption)
            }
        }
    }
}
