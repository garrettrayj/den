//
//  SearchView.swift
//  Den
//
//  Created by Garrett Johnson on 9/6/20.
//  Copyright © 2020 Garrett Johnson. All rights reserved.
//

import CoreData
import SwiftUI

import Grid

struct SearchView: View {
    @EnvironmentObject var searchManager: SearchManager

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                SearchFieldView()

                if searchManager.searchResults.count > 0 && searchManager.searchIsValid() {
                    ScrollView {
                        Grid(searchManager.searchResults, id: \.self) { sectionItems in
                            SearchResultView(items: sectionItems)
                        }
                        .gridStyle(StaggeredGridStyle(.vertical, tracks: Tracks.min(300), spacing: 16))
                        .padding()
                        .padding(.bottom, 64)
                    }
                } else if searchManager.searchQuery == "" {
                    Text("Filter Current Headlines by Keyword").modifier(SimpleMessageModifier())
                } else if !searchManager.searchIsValid() {
                    Text("Minimum Three Characters Required to Search").modifier(SimpleMessageModifier())
                } else {
                    Text("No Results Found").modifier(SimpleMessageModifier())
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .background(Color(UIColor.secondarySystemBackground).edgesIgnoringSafeArea(.all))
            .navigationTitle("Search")
            .navigationBarTitleDisplayMode(.inline)

        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}
