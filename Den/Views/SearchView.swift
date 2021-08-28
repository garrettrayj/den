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
    @ObservedObject var searchViewModel: SearchViewModel

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                SearchFieldView(query: $searchViewModel.query, onCommit: searchViewModel.performItemSearch)

                if searchViewModel.queryIsValid == false {
                    Text(searchViewModel.validationMessage ?? "Invalid search query")
                        .modifier(SimpleMessageModifier())
                } else if searchViewModel.queryIsValid == true {
                    if searchViewModel.results.count > 0 {
                        ScrollView {
                            Grid(searchViewModel.results, id: \.self) { sectionItems in
                                SearchResultView(items: sectionItems)
                            }
                            .gridStyle(StaggeredGridStyle(.vertical, tracks: Tracks.min(300), spacing: 16))
                            .padding()
                            .padding(.bottom, 64)
                        }
                    } else {
                        Text("No results found").modifier(SimpleMessageModifier())
                    }
                } else {
                    Text("Filter items by keyword").modifier(SimpleMessageModifier())
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
