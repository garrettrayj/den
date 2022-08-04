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
    @ObservedObject var profile: Profile

    @Binding var query: String

    var body: some View {
        Group {
            if query == "" {
                StatusBoxView(
                    message: Text("Searching \(profile.wrappedName)"),
                    symbol: "magnifyingglass"
                )
            } else {
                SearchResultsView(query: query, profile: profile)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(Color(UIColor.systemGroupedBackground).edgesIgnoringSafeArea(.all))
        .navigationTitle("Search")
    }
}
