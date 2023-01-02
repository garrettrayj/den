//
//  SearchView.swift
//  Den
//
//  Created by Garrett Johnson on 9/6/20.
//  Copyright © 2020 Garrett Johnson
//

import CoreData
import SwiftUI

struct SearchView: View {
    @ObservedObject var profile: Profile
    @ObservedObject var searchModel: SearchModel

    var body: some View {
        Group {
            if searchModel.query == "" {
                StatusBoxView(
                    message: Text("Searching \(profile.wrappedName)"),
                    symbol: "magnifyingglass"
                )
            } else {
                SearchResultsView(searchModel: searchModel, profile: profile)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(Color(UIColor.systemGroupedBackground).edgesIgnoringSafeArea(.all))
        .navigationTitle("Search")
    }
}
