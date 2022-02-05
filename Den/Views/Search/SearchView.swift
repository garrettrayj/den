//
//  SearchView.swift
//  Den
//
//  Created by Garrett Johnson on 9/6/20.
//  Copyright © 2020 Garrett Johnson. All rights reserved.
//

import CoreData
import SwiftUI

struct SearchView: View {
    @EnvironmentObject private var refreshManager: RefreshManager
    @ObservedObject var viewModel: SearchViewModel

    var profile: Profile

    var body: some View {
        Group {
            if refreshManager.isRefreshing {
                StatusBoxView(
                    message: Text("Waiting for refresh to complete…"),
                    symbol: "hourglass"
                )
            } else if viewModel.isChangedOrEmpty {
                StatusBoxView(
                    message: Text("Searching Current Items"),
                    caption: Text("for words in titles"),
                    symbol: "magnifyingglass"
                )
            } else {
                SearchResultsView(query: viewModel.query, profile: profile)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(Color(UIColor.systemGroupedBackground).edgesIgnoringSafeArea(.all))
        .navigationTitle("Search")
    }
}
