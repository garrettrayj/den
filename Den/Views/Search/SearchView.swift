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
    @EnvironmentObject var profileManager: ProfileManager
    @EnvironmentObject var refreshManager: RefreshManager

    var query: String = ""

    var body: some View {
        Group {
            if refreshManager.isRefreshing {
                StatusBoxView(message: "Waiting on Refresh…", symbol: "hourglass")
            } else if query == "" {
                StatusBoxView(
                    message: "Searching “\(profileManager.activeProfileName)” Profile",
                    symbol: "magnifyingglass"
                )
            } else {
                if profileManager.activeProfile != nil {
                    SearchResultsView(query: query, profile: profileManager.activeProfile!)
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(Color(UIColor.systemGroupedBackground).edgesIgnoringSafeArea(.all))
        .navigationTitle("Search")
    }
}
